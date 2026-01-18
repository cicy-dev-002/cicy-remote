#!/usr/bin/env python
"""
Test script to verify server startup configuration and information display.
"""

import subprocess
import sys
import argparse
import time


def test_server_help():
    print("Testing --help option...")
    print("=" * 60)
    result = subprocess.run(
        [sys.executable, "server.py", "--help"], capture_output=True, text=True
    )
    print(result.stdout)
    print("=" * 60 + "\n")


def test_server_startup_stdio():
    print("Testing server startup with stdio transport...")
    print("=" * 60)
    proc = subprocess.Popen(
        [sys.executable, "server.py", "--transport", "stdio"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    time.sleep(0.3)
    proc.terminate()
    stdout, stderr = proc.communicate(timeout=0.5)

    print(stdout if stdout else "(no output)")
    if stderr:
        print("STDERR:", stderr)
    print("=" * 60 + "\n")


def test_server_startup_http():
    print("Testing server startup with streamable-http transport...")
    print("=" * 60)
    proc = subprocess.Popen(
        [
            sys.executable,
            "server.py",
            "--transport",
            "streamable-http",
            "--host",
            "127.0.0.1",
            "--port",
            "8050",
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    time.sleep(0.3)
    proc.terminate()
    stdout, stderr = proc.communicate(timeout=0.5)

    print(stdout if stdout else "(no output)")
    if stderr:
        print("STDERR:", stderr)
    print("=" * 60 + "\n")


def test_server_startup_sse():
    print("Testing server startup with sse transport...")
    print("=" * 60)
    proc = subprocess.Popen(
        [
            sys.executable,
            "server.py",
            "--transport",
            "sse",
            "--host",
            "0.0.0.0",
            "--port",
            "9000",
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    time.sleep(0.3)
    proc.terminate()
    stdout, stderr = proc.communicate(timeout=0.5)

    print(stdout if stdout else "(no output)")
    if stderr:
        print("STDERR:", stderr)
    print("=" * 60 + "\n")


def main():
    print("\n" + "=" * 60)
    print("PyAutoGUI MCP Server - Startup Test")
    print("=" * 60 + "\n")

    parser = argparse.ArgumentParser(description="Test server startup")
    parser.add_argument(
        "--test",
        choices=["all", "help", "stdio", "http", "sse"],
        default="all",
        help="Which test to run",
    )

    args = parser.parse_args()

    if args.test in ["all", "help"]:
        test_server_help()
    if args.test in ["all", "stdio"]:
        test_server_startup_stdio()
    if args.test in ["all", "http"]:
        test_server_startup_http()
    if args.test in ["all", "sse"]:
        test_server_startup_sse()

    print("Tests completed!")


if __name__ == "__main__":
    import time

    main()
