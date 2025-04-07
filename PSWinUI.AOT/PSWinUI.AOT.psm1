# WinUIDSL.psm1
# 本模块实现基于 DSL 的 WinUI 3 应用代码生成，
# 采用 PS+C# 混合开发的方式提升解析和项目更新的效率与可维护性。
# 使用时，请确保在项目中新建一个 DSL 脚本文件（如 ui.ps1），
# 然后在 PowerShell 控制台中运行 Invoke-DSLGeneration 以完成所有生成工作。
# 改为加载预编译好的程序集
Add-Type -Path "$PSScriptRoot\DSLHelper.dll"


#region 清除默认文件与生成文件夹管理

function Clear-DefaultFiles {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = (Get-Location).Path
    )
    Write-Host "清除项目中默认的 WinUI 3 文件..."
    # 根据实际项目调整默认文件列表（例如：App.xaml、MainWindow.xaml 等）
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
    param(
        [string]$ProjectRoot = (Get-Location).Path,
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
        [int]$Width = 800,
        [int]$Height = 600,
        [string]$OutputPath = ""
    )
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
        [string]$OnClickScript = "",
        [string]$XamlFile = ""
    )
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
    $content = Get-Content $XamlFile -Raw
    $buttonXaml = "    <Button Content='$ButtonText' x:Name='btn_$([System.Guid]::NewGuid().ToString('N'))' />`n"
    $newContent = $content -replace '</Grid>', "$buttonXaml</Grid>"
    $newContent | Out-File -Encoding utf8 $XamlFile
    Write-Host "按钮添加成功。"
}

function Add-UILabel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LabelText,
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
        [Parameter(Mandatory = $true)]
        [string]$Placeholder,
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
        [Parameter(Mandatory = $true)]
        [string]$Name,
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

#region 使用 C# 辅助生成代码后置文件

function Generate-CodeBehind {
    [CmdletBinding()]
    param(
        [string]$OutputPath = ""
    )
    if ([string]::IsNullOrEmpty($OutputPath)) {
        $projectRoot = (Get-Location).Path
        $generatedFolder = Ensure-GeneratedFolder -ProjectRoot $projectRoot
        $OutputPath = Join-Path $generatedFolder "MainWindow.xaml.cs"
    }
    Write-Host "生成 C# 代码后置文件： $OutputPath"
    # 调用 C# 辅助类 DSLHelper 生成代码
    [DSLHelper]::GenerateCodeBehind($OutputPath)
    Write-Host "代码后置文件生成完成。"
}

#endregion

#region 使用 C# 辅助更新项目文件

function Update-ProjectFile {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = (Get-Location).Path,
        [string]$GeneratedFolder = "Generated"
    )
    # 查找项目文件（*.csproj），这里选择第一个匹配的文件
    $csproj = Get-ChildItem -Path $ProjectRoot -Filter *.csproj -Recurse | Select-Object -First 1
    if (-not $csproj) {
       Write-Error "无法找到项目文件 (*.csproj)。"
       return
    }
    Write-Host "更新项目文件： $($csproj.FullName)"
    # 调用 C# 辅助类 DSLHelper 更新项目文件，添加 Generated 下的 *.xaml 与 *.cs 项
    [DSLHelper]::UpdateProjectFile($csproj.FullName, $GeneratedFolder)
    Write-Host "项目文件更新完成。"
}

#endregion

#region 主生成入口
# 注意：为避免在 ui.ps1 中尚未完成所有准备时调用本命令，
# 建议用户在编辑完 DSL 脚本后，通过控制台运行该命令
# (例如在 PowerShell 控制台中执行: Invoke-DSLGeneration)
function Invoke-DSLGeneration {
    [CmdletBinding()]
    param(
        [string]$DslScriptPath = ".\ui.ps1"
    )
    Write-Host "==================== 开始 DSL 生成流程 ===================="
    # 1. 清除默认文件（VS 默认模板文件）
    Clear-DefaultFiles
    # 2. 确保生成文件夹存在
    Ensure-GeneratedFolder
    # 3. 执行用户 DSL 脚本（注意：用户的 ui.ps1 文件中只包含 DSL 命令，不再调用 Invoke-DSLGeneration）
    if (-not (Test-Path $DslScriptPath)) {
        Write-Error "找不到 DSL 脚本文件： $DslScriptPath，请确认文件存在于项目根目录。"
        return
    }
    try {
        Write-Host "正在执行 DSL 脚本： $DslScriptPath"
        . $DslScriptPath
        Write-Host "DSL 脚本执行完成。"
    }
    catch {
        Write-Error "执行 DSL 脚本时发生错误： $_"
    }
    # 4. 生成 C# 后置代码文件（包含错误映射 #line 指令）
    Generate-CodeBehind
    # 5. 更新项目文件，确保 Generated 文件夹下文件正确参与编译
    Update-ProjectFile
    Write-Host "==================== DSL 生成流程完成 ===================="
}

#endregion

#region 模块导出

Export-ModuleMember -Function Clear-DefaultFiles, Ensure-GeneratedFolder, New-WinUIWindow, Add-UIButton, Add-UILabel, Add-UITextBox, Add-UIListView, Generate-CodeBehind, Update-ProjectFile, Invoke-DSLGeneration

#endregion