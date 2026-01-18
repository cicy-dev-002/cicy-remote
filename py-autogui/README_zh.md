# PyAutoGUI MCP Server

一个使用 PyAutoGUI 提供 GUI 自动化能力的 MCP (Model Context Protocol) 服务器。专为 Windows 坐标调试设计。

## 功能特性

- **文本输入**: 使用键盘输入文本
- **鼠标控制**: 点击、移动和滚动
- **截图**: 将屏幕捕获为图像或 base64 格式
- **键盘快捷键**: 按单个键或组合键
- **视觉调试**: 显示矩形覆盖层用于坐标调试（仅限 Windows）

## 安装

安装依赖项：
```bash
pip install -r requirements.txt
```

## 运行

运行服务器：
```bash
python server.py
```

## 可用工具

| 工具 | 描述 |
|------|-------------|
| `type_text(text, interval)` | 输入文本，可选键入间隔 |
| `click(x, y, clicks, button)` | 在坐标处点击或当前位置 |
| `screenshot(save_path)` | 截图并保存到文件或返回 base64 |
| `get_mouse_position()` | 获取当前鼠标坐标 |
| `key_press(keys)` | 按键盘键（例如 'enter', 'ctrl+c'） |
| `hotkey_press(*keys)` | 同时按多个键 |
| `move_mouse(x, y, duration)` | 将鼠标移动到坐标并动画 |
| `scroll(clicks)` | 滚动鼠标滚轮 |
| `open_rect()` | 打开 Windows 截图工具 |
| `show_window_size()` | 获取活动窗口大小（仅限 Windows） |
| `rect_info()` | 获取截图工具窗口的位置和大小（仅限 Windows） |

## 安全

服务器包含故障安全机制，如果鼠标移动到屏幕左上角，会中断脚本。

## 平台

`rect_info` 工具专为 Windows 设计，使用 Windows API 创建覆盖窗口。其他工具是跨平台的。

## 使用示例

```python
# 输入文本
type_text("Hello World")

# 在坐标处点击
click(x=500, y=300)

# 截图
screenshot(save_path="screenshot.png")

# 获取鼠标位置
get_mouse_position()

# 显示矩形用于坐标调试（仅限 Windows）
show_rectangle(x=100, y=100, width=200, height=150, color="red", duration=10)
```

## 测试

### 单元测试

运行自动化单元测试：
```bash
python -m pytest test_show_rectangle.py -v
```

### 手动测试

运行手动测试脚本进行视觉验证（仅限 Windows）：
```bash
python test_rectangle_manual.py
```

这提供了几种测试模式：
1. 基本矩形显示
2. 角落位置
3. 不同大小
4. 持续时间计时
5. 交互模式
6. 运行所有测试

### 测试覆盖

单元测试涵盖：
- 基本功能和返回值
- 默认和自定义参数
- Windows API 模拟
- 平台特定行为
- 边界情况（负坐标、大尺寸）
- 线程创建

手动测试验证 Windows 上的实际窗口显示。

## OpenCode 集成

此 MCP 服务器可以与 [OpenCode](https://opencode.ai) 集成，以实现 AI 驱动的 GUI 自动化能力。

### 快速设置

1. **在后台启动 MCP 服务器：**
   ```bash
   # Windows 上
   start_server.bat

   # Linux/macOS 上
   chmod +x start_server.sh
   ./start_server.sh
   ```

2. **配置 OpenCode：**
   将以下内容添加到您的 OpenCode 配置文件（`~/.config/opencode/config.json`）：

   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "mcp": {
       "pyautogui": {
         "type": "remote",
         "url": "http://localhost:8050/mcp",
         "enabled": true,
         "description": "PyAutoGUI MCP Server - GUI automation tools"
       }
     }
   }
   ```

3. **在 OpenCode 中使用：**
   在您的 OpenCode 提示中，您现在可以使用 PyAutoGUI 工具：
   ```
   截取当前屏幕的截图并保存为 screenshot.png。使用 pyautogui
   ```

   ```
   将鼠标移动到坐标 (500, 300) 并点击。使用 pyautogui
   ```

### 系统服务设置（Linux）

用于生产使用，安装为系统服务：

1. 复制服务文件：
   ```bash
   sudo cp pyautogui-mcp.service /etc/systemd/system/
   ```

2. 编辑服务文件以设置正确的路径和用户：
   ```bash
   sudo nano /etc/systemd/system/pyautogui-mcp.service
   # 更新 WorkingDirectory、ExecStart 和 User
   ```

3. 启用并启动服务：
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable pyautogui-mcp
   sudo systemctl start pyautogui-mcp
   sudo systemctl status pyautogui-mcp
   ```

### 远程访问

对于远程访问，您可以通过反向代理或云服务公开服务器。确保：

1. 配置适当的身份验证/授权
2. 在生产中使用 HTTPS
3. 将网络访问限制为受信任的 IP

服务器支持所有 MCP 传输模式：
- `stdio` - 用于本地 CLI 使用
- `streamable-http` - 用于 HTTP API 访问
- `sse` - 用于服务器发送事件

### 配置文件

在 `opencode-mcp-config.json` 中提供了示例 OpenCode 配置，您可以将其合并到全局 OpenCode 配置中。