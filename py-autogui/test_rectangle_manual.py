#!/usr/bin/env python
"""
Manual test script for show_rectangle functionality.
This script allows you to test the actual rectangle display on Windows.
"""

import sys
import time
from server import show_rectangle


def test_basic_rectangle():
    print("\n" + "=" * 60)
    print("TEST 1: Basic Rectangle Display")
    print("=" * 60)
    print("Creating a red rectangle at (500, 400) with size 300x200")
    print("Duration: 3 seconds")
    print("Please verify that the rectangle appears on screen...")
    print("=" * 60 + "\n")

    result = show_rectangle(500, 400, 300, 200, "red", 3)
    print(f"Function returned: {result}")
    time.sleep(4)


def test_corner_positions():
    print("\n" + "=" * 60)
    print("TEST 2: Corner Positions")
    print("=" * 60)
    print("Testing rectangles at different screen corners")
    print("Duration: 2 seconds each")
    print("=" * 60 + "\n")

    corners = [
        (100, 100, "Top-left"),
        (1000, 100, "Top-right"),
        (100, 600, "Bottom-left"),
        (1000, 600, "Bottom-right"),
    ]

    for x, y, position in corners:
        print(f"\nShowing rectangle at {position}: ({x}, {y})")
        result = show_rectangle(x, y, 200, 150, "red", 2)
        print(f"Function returned: {result}")
        time.sleep(2.5)


def test_multiple_sizes():
    print("\n" + "=" * 60)
    print("TEST 3: Different Sizes")
    print("=" * 60)
    print("Testing rectangles with different sizes")
    print("Duration: 2 seconds each")
    print("=" * 60 + "\n")

    sizes = [
        (500, 300, 100, 100, "Small"),
        (500, 300, 200, 200, "Medium"),
        (500, 300, 400, 300, "Large"),
    ]

    for x, y, width, height, size in sizes:
        print(f"\nShowing {size} rectangle: {width}x{height}")
        result = show_rectangle(x, y, width, height, "red", 2)
        print(f"Function returned: {result}")
        time.sleep(2.5)


def test_duration():
    print("\n" + "=" * 60)
    print("TEST 4: Duration Test")
    print("=" * 60)
    print("Testing rectangle with 5-second duration")
    print("Please count the seconds to verify timing...")
    print("=" * 60 + "\n")

    print("Starting rectangle...")
    result = show_rectangle(600, 350, 300, 200, "red", 5)
    print(f"Function returned: {result}")

    for i in range(5, 0, -1):
        print(f"Rectangle will disappear in {i} seconds...")
        time.sleep(1)

    print("Rectangle should have disappeared now.")


def interactive_test():
    print("\n" + "=" * 60)
    print("INTERACTIVE MODE")
    print("=" * 60)
    print("Enter coordinates to display rectangles")
    print("Type 'quit' to exit")
    print("=" * 60 + "\n")

    while True:
        try:
            cmd = input("Enter command (x,y,width,height,duration) or 'quit': ").strip()

            if cmd.lower() == "quit":
                break

            if not cmd:
                continue

            parts = cmd.split(",")
            if len(parts) < 4:
                print("Invalid format. Use: x,y,width,height[,duration]")
                continue

            x = int(parts[0].strip())
            y = int(parts[1].strip())
            width = int(parts[2].strip())
            height = int(parts[3].strip())
            duration = int(parts[4].strip()) if len(parts) > 4 else 3

            print(
                f"\nDisplaying rectangle at ({x}, {y}) with size {width}x{height} for {duration}s"
            )
            result = show_rectangle(x, y, width, height, "red", duration)
            print(f"Result: {result}\n")

        except ValueError:
            print("Invalid input. Please enter numbers.")
        except KeyboardInterrupt:
            break

    print("\nExiting interactive mode.")


def main():
    print("\n" + "=" * 60)
    print("PyAutoGUI MCP Server - Rectangle Display Manual Test")
    print("=" * 60)
    print(f"Platform: {sys.platform}")
    print("=" * 60)

    if sys.platform != "win32":
        print("\nWARNING: This test is designed for Windows.")
        print("On non-Windows platforms, the rectangle may not appear.")
        print("The function will still return success messages.")
        print("\nTo run full visual tests, execute on Windows.")
        return

    print("\nAvailable test modes:")
    print("1. Basic rectangle display")
    print("2. Corner positions")
    print("3. Different sizes")
    print("4. Duration timing")
    print("5. Interactive mode")
    print("6. Run all tests")

    try:
        choice = input("\nSelect test mode (1-6): ").strip()

        if choice == "1":
            test_basic_rectangle()
        elif choice == "2":
            test_corner_positions()
        elif choice == "3":
            test_multiple_sizes()
        elif choice == "4":
            test_duration()
        elif choice == "5":
            interactive_test()
        elif choice == "6":
            test_basic_rectangle()
            test_corner_positions()
            test_multiple_sizes()
            test_duration()
        else:
            print("Invalid choice. Running basic test...")
            test_basic_rectangle()

    except KeyboardInterrupt:
        print("\n\nTest interrupted by user.")
    except Exception as e:
        print(f"\n\nError: {e}")

    print("\n" + "=" * 60)
    print("Test completed")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    main()
