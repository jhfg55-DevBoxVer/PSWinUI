using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace PSWinUI
{
    public static class WinUIAppWrapper
    {
        /// <summary>
        /// 启动一个简单窗口，窗口中居中显示指定的消息。
        /// </summary>
        /// <param name="title">窗口标题（可选）</param>
        /// <param name="message">窗口中显示的文字</param>
        public static void ShowWindow(string title, string message)
        {
            Application.Start(_ =>
            {
                // 注意：在 WinUI 3 中 Window 对象通常不直接暴露 Title 属性，
                // 所以在本示例里仅聚焦于演示创建窗口和显示文本。
                var window = new Window();

                // 创建一个容器（Grid）并添加一个居中的 TextBlock
                var grid = new Grid();
                var textBlock = new TextBlock
                {
                    Text = message,
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Center,
                    FontSize = 24
                };
                grid.Children.Add(textBlock);

                // 将容器设置为窗口内容并激活窗口
                window.Content = grid;
                window.Activate();
            });
        }
    }
}