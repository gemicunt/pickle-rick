#!/usr/bin/env python3
import argparse
import subprocess
import sys
import os
import time
import textwrap

def print_box(lines, color_code="\033[32m"): # Default green
    width = 90
    print(f"{color_code}┌" + "─" * (width - 2) + "┐\033[0m")
    for line in lines:
        print(f"{color_code}│\033[0m {line:<{width - 4}} {color_code}│\033[0m")
    print(f"{color_code}└" + "─" * (width - 2) + "┘\033[0m")

def main():
    parser = argparse.ArgumentParser(description="Spawn a Pickle Worker")
    parser.add_argument("task", help="The task description")
    parser.add_argument("--ticket-id", required=True, help="Ticket ID")
    parser.add_argument("--ticket-path", required=True, help="Path to ticket directory")
    parser.add_argument("--timeout", type=int, default=300, help="Timeout in seconds")
    
    args = parser.parse_args()

    # Ensure ticket directory exists
    os.makedirs(args.ticket_path, exist_ok=True)
    session_log = os.path.join(args.ticket_path, "worker_session.log")

    # Start UI
    width = 90
    color_code = "\033[32m"
    print_box([
        "🥒 **Spawning Pickle Clone**",
        f"Task: {textwrap.shorten(args.task, width=70)}",
        f"ID:   {args.ticket_id}",
        f"Log:  {session_log}",
        f"PID:  {os.getpid()}"
    ])

    cmd = [
        "gemini",
        "-s", # Silent mode (implied by user request)
        "-y", # Auto-confirm
        "-p", f'/pickle-worker "{args.task}" --completion-promise "I AM DONE"'
    ]

    # Allow test override
    if "PICKLE_WORKER_CMD_OVERRIDE" in os.environ:
        import shlex
        cmd = shlex.split(os.environ["PICKLE_WORKER_CMD_OVERRIDE"])

    start_time = time.time()
    return_code = 1
    result_text = "FAILED"
    
    try:
        with open(session_log, "w") as log_file:
            # We run it and wait
            env = os.environ.copy()
            env["PICKLE_STATE_FILE"] = os.path.join(args.ticket_path, "state.json")
            
            process = subprocess.Popen(
                cmd,
                stdout=log_file,
                stderr=subprocess.STDOUT,
                text=True,
                cwd=os.getcwd(), # Run in current repo context
                env=env
            )
            
            # Polling loop with visual feedback
            spinner = "|/-\\"
            idx = 0
            while True:
                ret_code = process.poll()
                if ret_code is not None:
                    return_code = ret_code
                    break
                
                if time.time() - start_time > args.timeout:
                    process.kill()
                    return_code = 124 # Timeout
                    with open(session_log, "a") as f:
                        f.write("\n\n[TIMEOUT] Worker killed after timeout.\n")
                    break
                
                # Visual heartbeat
                sys.stdout.write(f"\r{color_code}│\033[0m Working... {spinner[idx % len(spinner)]}")
                sys.stdout.flush()
                idx += 1
                time.sleep(0.2)

            # Clear the working line
            sys.stdout.write("\r" + " " * width + "\r") 
            sys.stdout.flush()

    except Exception as e:
        with open(session_log, "a") as f:
            f.write(f"\n\n[ERROR] Script failed: {e}\n")
        return_code = 1

    # Check for success marker in log
    is_success = False
    result_snippet = "No output"
    
    if os.path.exists(session_log):
        with open(session_log, "r") as f:
            content = f.read()
            if "<promise>I AM DONE</promise>" in content:
                is_success = True
                result_snippet = "I AM DONE"
            else:
                # Grab last few lines for error context
                lines = content.strip().split('\n')
                result_snippet = lines[-1] if lines else "Empty log"

    status_icon = "✅ SUCCESS" if is_success else "❌ FAILED"
    color = "\033[32m" if is_success else "\033[31m" # Green or Red

    print_box([
        "--- 🥒 Pickle Report ---",
        f"Task:    {textwrap.shorten(args.task, width=70)}",
        f"ID:      {args.ticket_id}",
        f"Status:  {status_icon} ({return_code})",
        f"Result:  {textwrap.shorten(result_snippet, width=70)}"
    ], color_code=color)

    if not is_success:
        sys.exit(1)

if __name__ == "__main__":
    main()
