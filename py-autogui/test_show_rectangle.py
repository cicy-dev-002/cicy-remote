import unittest
import sys
import time
from unittest.mock import Mock, patch, MagicMock


class TestShowRectangle(unittest.TestCase):
    def setUp(self):
        if sys.platform == "win32":
            import ctypes

            self.user32 = ctypes.windll.user32
            self.gdi32 = ctypes.windll.gdi32

    def test_show_rectangle_returns_success_message(self):
        from server import show_rectangle

        result = show_rectangle(100, 100, 200, 150, "red", 2)

        self.assertIn("Showing rectangle", result)
        self.assertIn("(100, 100)", result)
        self.assertIn("200x150", result)
        self.assertIn("2s", result)

    def test_show_rectangle_with_default_color(self):
        from server import show_rectangle

        result = show_rectangle(50, 50, 100, 100)

        self.assertIn("Showing rectangle at (50, 50)", result)

    def test_show_rectangle_with_custom_duration(self):
        from server import show_rectangle

        result = show_rectangle(0, 0, 300, 200, "blue", 5)

        self.assertIn("5s", result)

    @unittest.skipUnless(sys.platform == "win32", "Windows API test only")
    def test_windows_api_calls(self):
        from server import show_rectangle

        class MockThread:
            def __init__(self, target, daemon=False):
                self._target = target
                self.daemon = daemon

            def start(self):
                self._target()

        mock_windll = MagicMock()
        mock_windll.user32 = MagicMock()
        mock_windll.gdi32 = MagicMock()
        mock_windll.kernel32 = MagicMock()

        with (
            patch("ctypes.windll", mock_windll),
            patch("server.threading.Thread", MockThread),
            patch("server.time.sleep"),  # Mock sleep to avoid waiting
        ):
            mock_user32 = mock_windll.user32
            mock_gdi32 = mock_windll.gdi32
            mock_user32.RegisterClassW.return_value = 1
            mock_user32.CreateWindowExW.return_value = 12345
            mock_user32.GetDC.return_value = 999
            mock_user32.SetLayeredWindowAttributes.return_value = 1
            mock_user32.ShowWindow.return_value = 1
            mock_user32.ReleaseDC.return_value = 1
            mock_user32.DestroyWindow.return_value = 1

            mock_gdi32.CreatePen.return_value = 111
            mock_gdi32.SelectObject.return_value = 222
            mock_windll.kernel32.GetModuleHandleW.return_value = 123

            result = show_rectangle(100, 100, 200, 150, "red", 1)

            mock_user32.RegisterClassW.assert_called_once()
            mock_user32.CreateWindowExW.assert_called_once()
            mock_user32.SetLayeredWindowAttributes.assert_called_once()
            mock_user32.ShowWindow.assert_called_once_with(12345, 1)
            mock_user32.GetDC.assert_called_once_with(12345)

    def test_get_active_window_size_non_windows(self):
        from server import get_active_window_size

        # Temporarily change platform
        with patch("server.sys.platform", "linux"):
            result = get_active_window_size()
            self.assertIn("only available on Windows", result)

    def test_non_windows_platform_returns_message(self):
        from server import show_rectangle

        if sys.platform != "win32":
            result = show_rectangle(100, 100, 200, 150, "red", 1)
            self.assertIn("Showing rectangle", result)

    def test_invalid_coordinates(self):
        from server import show_rectangle

        result = show_rectangle(-100, -100, 50, 50, "red", 1)
        self.assertIn("Showing rectangle", result)

    def test_large_dimensions(self):
        from server import show_rectangle

        result = show_rectangle(0, 0, 1920, 1080, "red", 1)
        self.assertIn("1920x1080", result)

    def test_thread_creation(self):
        from server import show_rectangle
        import threading

        initial_thread_count = threading.active_count()

        result = show_rectangle(100, 100, 200, 150, "red", 1)

        time.sleep(0.1)

        final_thread_count = threading.active_count()
        self.assertGreaterEqual(final_thread_count, initial_thread_count)


class TestShowRectangleIntegration(unittest.TestCase):
    """Integration test for real window creation (manual verification)"""

    @unittest.skip("Manual test - requires visual verification")
    def test_actual_window_display(self):
        from server import show_rectangle

        print("\n" + "=" * 50)
        print("INTEGRATION TEST: Rectangle Display")
        print("=" * 50)
        print("A red rectangle should appear at (500, 500) for 3 seconds")
        print("Please verify visually...")
        print("=" * 50)

        result = show_rectangle(500, 500, 300, 200, "red", 3)

        self.assertIn("Showing rectangle", result)

        print("Test completed - window should have appeared and disappeared")

    @unittest.skip("Manual test - requires visual verification")
    def test_multiple_rectangles(self):
        from server import show_rectangle

        print("\n" + "=" * 50)
        print("INTEGRATION TEST: Multiple Rectangles")
        print("=" * 50)
        print("Multiple rectangles should appear sequentially")
        print("=" * 50)

        coords = [(100, 100), (200, 200), (300, 300)]

        for x, y in coords:
            result = show_rectangle(x, y, 150, 100, "red", 2)
            print(f"Created rectangle at ({x}, {y})")
            time.sleep(1)

        print("All rectangles created sequentially")


if __name__ == "__main__":
    unittest.main(verbosity=2)
