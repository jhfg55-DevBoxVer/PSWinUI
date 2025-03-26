# WinUIDSL.psm1
# 此模块实现一个 WinUI 3 DSL 生成方案，帮助用户在 VS 中利用一个 PowerShell 脚本生成 XAML 和 C# 代码（带有错误映射）。
# 用户的基本操作流程：在项目中编写 ui.ps1 脚本，然后在脚本末尾调用 Invoke-DSLGeneration 即可。
# 模块还提供了更新项目文件将生成目录添加为编译项的功能。

#region 清除默认文件与生成文件夹管理

function Clear-DefaultFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Get-Location).Path
    )
    Write-Host "清除项目中默认的 WinUI 3 文件..."
    # 请根据实际情况调整 VS 模板中默认的文件名称列表 
    $filesToRemove = @("App.xaml", "App.xaml.cs", "MainWindow.xaml", "MainWindow.xaml.cs")
    foreach ($file in $filesToRemove) {
        $filePath = Join-Path $ProjectRoot $file
        if (Test-Path $filePath) {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
            Write-Host "已删除: $filePath"
        }
    }
}

function Ensure-GeneratedFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Get-Location).Path,
        [Parameter(Mandatory = $false)]
        [string]$GeneratedFolderName = "Generated"
    )
    $folderPath = Join-Path $ProjectRoot $GeneratedFolderName
    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath | Out-Null
        Write-Host "已创建 Generated 文件夹： $folderPath"
    }
    else {
        Write-Host "Generated 文件夹已存在： $folderPath"
    }
    return $folderPath
}

#endregion

#region DSL 命令实现

function New-WinUIWindow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter()]
        [int]$Width = 800,
        [Parameter()]
        [int]$Height = 600,
        [Parameter()]
        [string]$OutputPath = ""
    )

    # 默认输出路径：Generated\MainWindow.xaml
    if ([string]::IsNullOrEmpty($OutputPath)) {
        $projectRoot = (Get-Location).Path
        $generatedFolder = Ensure-GeneratedFolder -ProjectRoot $projectRoot
        $OutputPath = Join-Path $generatedFolder "MainWindow.xaml"
    }

    Write-Host "生成 WinUI 窗口 XAML 文件： $OutputPath"

    $xamlTemplate = @"
<Window
    x:Class="GeneratedApp.MainWindow"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="$Title" Height="$Height" Width="$Width">
    <Grid>
        <!-- 此处将由其他控件追加 -->
    </Grid>
</Window>
"@

    $outDir = Split-Path $OutputPath
    if (-not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir | Out-Null
    }
    $xamlTemplate | Out-File -Encoding utf8 $OutputPath
    Write-Host "窗口 XAML 文件生成完成。"
}

function Add-UIButton {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ButtonText,
        [Parameter()]
        [string]$OnClickScript = "",
        [Parameter()]
        [string]$XamlFile = ""
    )
    
    # 默认在 Generated\MainWindow.xaml 中添加控件
    if ([string]::IsNullOrEmpty($XamlFile)) {
        $projectRoot = (Get-Location).Path
        $generatedFolder = Ensure-GeneratedFolder -ProjectRoot $projectRoot
        $XamlFile = Join-Path $generatedFolder "MainWindow.xaml"
    }
    
    Write-Host "在 $XamlFile 中添加按钮： '$ButtonText'"
    if (-not (Test-Path $XamlFile)) {
        Write-Error "指定的 XAML 文件 $XamlFile 不存在，请先调用 New-WinUIWindow 创建窗口模板。"
        return
    }

    # 简单将按钮控件插入到 Grid 内 "</Grid>" 结束标签之前
    $content = Get-Content $XamlFile -Raw
    $buttonXaml = "    <Button Content='$ButtonText' x:Name='btn_$([System.Guid]::NewGuid().ToString('N'))' />`n"
    $newContent = $content -replace '</Grid>', "$buttonXaml</Grid>"
    $newContent | Out-File -Encoding utf8 $XamlFile
    Write-Host "按钮添加成功。"
}

function Add-UILabel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$LabelText,
        [Parameter()]
        [string]$XamlFile = ""
    )
    if ([string]::IsNullOrEmpty($XamlFile)) {
        $projectRoot = (Get-Location).Path
        $generatedFolder = Ensure-GeneratedFolder -ProjectRoot $projectRoot
        $XamlFile = Join-Path $generatedFolder "MainWindow.xaml"
    }
    Write-Host "在 $XamlFile 中添加标签： '$LabelText'"
    if (-not (Test-Path $XamlFile)) {
         Write-Error "指定的 XAML 文件 $XamlFile 不存在，请先调用 New-WinUIWindow。"
         return
    }
    $content = Get-Content $XamlFile -Raw
    $labelXaml = "    <TextBlock Text='$LabelText' Margin='5' />`n"
    $newContent = $content -replace '</Grid>', "$labelXaml</Grid>"
    $newContent | Out-File -Encoding utf8 $XamlFile
    Write-Host "标签添加成功。"
}

function Add-UITextBox {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Placeholder,
        [Parameter()]
        [string]$XamlFile = ""
    )
    if ([string]::IsNullOrEmpty($XamlFile)) {
         $projectRoot = (Get-Location).Path
         $generatedFolder = Ensure-GeneratedFolder -ProjectRoot $projectRoot
         $XamlFile = Join-Path $generatedFolder "MainWindow.xaml"
    }
    Write-Host "在 $XamlFile 中添加文本框： Placeholder='$Placeholder'"
    if (-not (Test-Path $XamlFile)) {
         Write-Error "指定的 XAML 文件 $XamlFile 不存在，请先调用 New-WinUIWindow。"
         return
    }
    $content = Get-Content $XamlFile -Raw
    $textBoxXaml = "    <TextBox PlaceholderText='$Placeholder' Margin='5' />`n"
    $newContent = $content -replace '</Grid>', "$textBoxXaml</Grid>"
    $newContent | Out-File -Encoding utf8 $XamlFile
    Write-Host "文本框添加成功。"
}

function Add-UIListView {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter()]
        [string]$XamlFile = ""
    )
    if ([string]::IsNullOrEmpty($XamlFile)) {
         $projectRoot = (Get-Location).Path
         $generatedFolder = Ensure-GeneratedFolder -ProjectRoot $projectRoot
         $XamlFile = Join-Path $generatedFolder "MainWindow.xaml"
    }
    Write-Host "在 $XamlFile 中添加 ListView 控件： Name='$Name'"
    if (-not (Test-Path $XamlFile)) {
         Write-Error "指定的 XAML 文件 $XamlFile 不存在，请先调用 New-WinUIWindow。"
         return
    }
    $content = Get-Content $XamlFile -Raw
    $listViewXaml = @"
    <ListView x:Name='$Name' Margin='5'>
        <ListViewItem Content='示例项 1' />
        <ListViewItem Content='示例项 2' />
    </ListView>
"@
    $newContent = $content -replace '</Grid>', "$listViewXaml`n</Grid>"
    $newContent | Out-File -Encoding utf8 $XamlFile
    Write-Host "ListView 控件添加成功。"
}

#endregion

#region 代码后置文件生成（包含 #line 指令实现错误映射）

function Generate-CodeBehind {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$OutputPath = ""
    )
    
    if ([string]::IsNullOrEmpty($OutputPath)) {
        $projectRoot = (Get-Location).Path
        $generatedFolder = Ensure-GeneratedFolder -ProjectRoot $projectRoot
        $OutputPath = Join-Path $generatedFolder "MainWindow.xaml.cs"
    }
    
    Write-Host "生成代码后置文件： $OutputPath"
    
    # 此处使用 #line 指令将后置代码映射到原始 DSL 脚本（假设文件名为 ui.ps1）
    $codeTemplate = @"
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace GeneratedApp
{
    public sealed partial class MainWindow : Window
    {
#line 1 "ui.ps1"
        public MainWindow()
        {
            this.InitializeComponent();
        }
#line default
    }
}
"@
    $outDir = Split-Path $OutputPath
    if (-not (Test-Path $outDir)) {
         New-Item -ItemType Directory -Path $outDir | Out-Null
         Write-Host "已创建目录： $outDir"
    }
    
    $codeTemplate | Out-File -Encoding utf8 $OutputPath
    Write-Host "代码后置文件生成完成。"
}

#endregion

#region 更新项目文件确保生成目录被包含

function Update-ProjectFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Get-Location).Path,
        [Parameter(Mandatory = $false)]
        [string]$GeneratedFolder = "Generated"
    )

    # 尝试找到项目文件（*.csproj），这里取第一个找到的
    $csproj = Get-ChildItem -Path $ProjectRoot -Filter *.csproj -Recurse | Select-Object -First 1
    if (-not $csproj) {
       Write-Error "无法找到项目文件 (*.csproj)。"
       return
    }
    Write-Host "更新项目文件： $($csproj.FullName)"

    [xml]$projXml = Get-Content $csproj.FullName
    # 为简化处理，不进行复杂的命名空间处理（通常 VS csproj 使用 MSBuild XML）
    # 检查是否已有包含 Generated\*.xaml 的 Page 项
    $foundXaml = $false
    foreach ($itemGroup in $projXml.Project.ItemGroup) {
        if ($itemGroup.Page) {
            foreach ($page in $itemGroup.Page) {
                if ($page.Include -like "$GeneratedFolder\*.xaml") {
                    $foundXaml = $true
                    break
                }
            }
        }
    }
    if (-not $foundXaml) {
       $itemGroup = $projXml.CreateElement("ItemGroup")
       $page = $projXml.CreateElement("Page")
       $page.SetAttribute("Include", "$GeneratedFolder\*.xaml")
       $itemGroup.AppendChild($page) | Out-Null
       $projXml.Project.AppendChild($itemGroup) | Out-Null
       Write-Host "已为 XAML 文件添加 ItemGroup。"
    } else {
       Write-Host "XAML 文件的引用已存在。"
    }
    
    $foundCs = $false
    foreach ($itemGroup in $projXml.Project.ItemGroup) {
        if ($itemGroup.Compile) {
            foreach ($compile in $itemGroup.Compile) {
                if ($compile.Include -like "$GeneratedFolder\*.cs") {
                    $foundCs = $true
                    break
                }
            }
        }
    }
    if (-not $foundCs) {
       $itemGroup2 = $projXml.CreateElement("ItemGroup")
       $compile = $projXml.CreateElement("Compile")
       $compile.SetAttribute("Include", "$GeneratedFolder\*.cs")
       $itemGroup2.AppendChild($compile) | Out-Null
       $projXml.Project.AppendChild($itemGroup2) | Out-Null
       Write-Host "已为 C# 文件添加 ItemGroup。"
    } else {
       Write-Host "C# 文件的引用已存在。"
    }
    
    $projXml.Save($csproj.FullName)
    Write-Host "项目文件更新完成。"
}

#endregion

#region 主生成入口

function Invoke-DSLGeneration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DslScriptPath = ".\ui.ps1"
    )

    Write-Host "==================== 开始 DSL 生成流程 ===================="

    # 1. 清除默认文件
    Clear-DefaultFiles

    # 2. 确保生成文件夹存在
    Ensure-GeneratedFolder

    # 3. 执行用户 DSL 脚本
    if (-not (Test-Path $DslScriptPath)) {
        Write-Error "找不到 DSL 脚本文件： $DslScriptPath，请在项目根目录创建该文件。"
        return
    }
    try {
        Write-Host "正在执行 DSL 脚本： $DslScriptPath"
        # 通过点操作符直接载入并执行用户脚本
        . $DslScriptPath
        Write-Host "DSL 脚本执行成功。"
    }
    catch {
        Write-Error "执行 DSL 脚本时发生错误： $_"
    }

    # 4. 生成代码后置文件（带 #line 指令实现错误映射）
    Generate-CodeBehind

    # 5. 更新项目文件，确保生成目录中的文件能被正确编译
    Update-ProjectFile

    Write-Host "==================== DSL 生成流程完成 ===================="
}

#endregion

#region 模块导出

Export-ModuleMember -Function Clear-DefaultFiles, Ensure-GeneratedFolder, New-WinUIWindow, Add-UIButton, Add-UILabel, Add-UITextBox, Add-UIListView, Generate-CodeBehind, Update-ProjectFile, Invoke-DSLGeneration

#endregion