using System;
using System.IO;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using Microsoft.UI.Xaml;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace PSWinUI
{
    /// <summary>
    /// An empty window that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainWindow : Window
    {
        PowerShell _ps;

        public MainWindow()
        {
            this.InitializeComponent();

            // 初始化 PowerShell 运行空间
            InitialPowerShell();
        }

        void InitialPowerShell()
        {
            // 创建默认运行空间，并加载我们的模块（假设模块文件已复制到输出目录）
            var runspace = RunspaceFactory.CreateRunspace();
            runspace.Open();

            _ps = PowerShell.Create();
            _ps.Runspace = runspace;

            // 导入模块，模块文件位于应用目录下
            string modulePath = System.IO.Path.Combine(AppContext.BaseDirectory, "PSWinUI.psd1");
            _ps.AddCommand("Import-Module")
               .AddParameter("Name", modulePath);

            _ps.Invoke();
            _ps.Commands.Clear();
        }

        // 在 UI 中调用该方法，比如点击按钮后
        private void OnCreateWindowClick(object sender, RoutedEventArgs e)
        {
            CreateNewWindow("My WinUI 3 Window", "Hello from embedded PowerShell!");
        }

        void CreateNewWindow(string title, string message)
        {
            // 调用自定义的 PS 命令。注意：由于在同一进程中，WinUI 3 初始化的流程需要注意线程问题。
            _ps.AddCommand("New-PSWinUIWindow")
               .AddParameter("Title", title)
               .AddParameter("Message", message);

            var results = _ps.Invoke();
            _ps.Commands.Clear();

            // 可添加错误处理等逻辑。
            if (_ps.HadErrors)
            {
                // 处理错误
            }
        }
    }
}
