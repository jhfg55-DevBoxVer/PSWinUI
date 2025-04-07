using System.Xml;

public class DSLHelper
{
    public static void UpdateProjectFile(string csprojPath, string generatedFolder)
    {
        XmlDocument doc = new XmlDocument();
        doc.Load(csprojPath);

        // 检查并添加包含 Generated\*.xaml 的 Page 项
        bool hasXaml = false;
        XmlNodeList pageNodes = doc.GetElementsByTagName("Page");
        foreach (XmlNode page in pageNodes)
        {
            if (page.Attributes != null && page.Attributes["Include"] != null &&
                page.Attributes["Include"].Value.Contains(generatedFolder))
            {
                hasXaml = true;
                break;
            }
        }
        if (!hasXaml)
        {
            XmlElement itemGroup = doc.CreateElement("ItemGroup");
            XmlElement pageElement = doc.CreateElement("Page");
            pageElement.SetAttribute("Include", generatedFolder + "\\\\*.xaml");
            itemGroup.AppendChild(pageElement);
            doc.DocumentElement.AppendChild(itemGroup);
        }

        // 检查并添加包含 Generated\*.cs 的 Compile 项
        bool hasCs = false;
        XmlNodeList compileNodes = doc.GetElementsByTagName("Compile");
        foreach (XmlNode compile in compileNodes)
        {
            if (compile.Attributes != null && compile.Attributes["Include"] != null &&
                compile.Attributes["Include"].Value.Contains(generatedFolder))
            {
                hasCs = true;
                break;
            }
        }
        if (!hasCs)
        {
            XmlElement itemGroup = doc.CreateElement("ItemGroup");
            XmlElement compileElement = doc.CreateElement("Compile");
            compileElement.SetAttribute("Include", generatedFolder + "\\\\*.cs");
            itemGroup.AppendChild(compileElement);
            doc.DocumentElement.AppendChild(itemGroup);
        }
        doc.Save(csprojPath);
    }

    public static void GenerateCodeBehind(string outputPath)
    {
        // 生成的 C# 后置文件带有 #line 指令映射到 DSL 脚本 (ui.ps1)
        string code = @"
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace GeneratedApp {
    public sealed partial class MainWindow : Window {
#line 1 ""ui.ps1""
        public MainWindow() {
            this.InitializeComponent();
        }
#line default
    }
}
";
        File.WriteAllText(outputPath, code);
    }
}