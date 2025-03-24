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

            // ��ʼ�� PowerShell ���пռ�
            InitialPowerShell();
        }

        void InitialPowerShell()
        {
            // ����Ĭ�����пռ䣬���������ǵ�ģ�飨����ģ���ļ��Ѹ��Ƶ����Ŀ¼��
            var runspace = RunspaceFactory.CreateRunspace();
            runspace.Open();

            _ps = PowerShell.Create();
            _ps.Runspace = runspace;

            // ����ģ�飬ģ���ļ�λ��Ӧ��Ŀ¼��
            string modulePath = System.IO.Path.Combine(AppContext.BaseDirectory, "PSWinUI.psd1");
            _ps.AddCommand("Import-Module")
               .AddParameter("Name", modulePath);

            _ps.Invoke();
            _ps.Commands.Clear();
        }

        // �� UI �е��ø÷�������������ť��
        private void OnCreateWindowClick(object sender, RoutedEventArgs e)
        {
            CreateNewWindow("My WinUI 3 Window", "Hello from embedded PowerShell!");
        }

        void CreateNewWindow(string title, string message)
        {
            // �����Զ���� PS ���ע�⣺������ͬһ�����У�WinUI 3 ��ʼ����������Ҫע���߳����⡣
            _ps.AddCommand("New-PSWinUIWindow")
               .AddParameter("Title", title)
               .AddParameter("Message", message);

            var results = _ps.Invoke();
            _ps.Commands.Clear();

            // ����Ӵ�������߼���
            if (_ps.HadErrors)
            {
                // �������
            }
        }
    }
}
