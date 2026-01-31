import pyautogui
from IPython.display import display, Image
import PIL.Image
import io

# 1. 截取当前屏幕
screenshot = pyautogui.screenshot()

# 2. 压缩图像（减小体积，方便在 Jupyter 中查看）
# 缩小到原图的 50%
width, height = screenshot.size
compressed_img = screenshot.resize((width // 2, height // 2), PIL.Image.Resampling.LANCZOS)

# 3. 将图像转换为字节流显示
byte_io = io.BytesIO()
compressed_img.save(byte_io, format='PNG')

print("--- 当前 Windows 桌面截图 (已压缩) ---")
display(Image(data=byte_io.getvalue()))