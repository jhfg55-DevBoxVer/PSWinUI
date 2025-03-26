# WinUIDSL.psm1
# 本模块用于实现基于 DSL 的 WinUI 3 应用代码生成，
# 用户在 VS 中通过自定义模板创建 WinUI 3 项目后，
# 在项目根目录编写 ui.ps1 脚本描述界面，最后调用 Invoke-DSLGeneration 完成代码生成。

#region 清除默认文件与生成目录

function Clear-DefaultFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Get-Location).Path
    )
    Write-Host "清除项目中默认的 WinUI 3 文件..."
    # 这里假定 VS 模板中产生的默认文件名称（根据实际项目调整）
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
    
    # 默认操作在 Generated\MainWindow.xaml 中追加按钮
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

    # 读取原有 XAML 内容，并将按钮标签添加到 <Grid> 结束标签之前
    $content = Get-Content $XamlFile -Raw
    $buttonXaml = "    <Button Content='$ButtonText' x:Name='btn_$([System.Guid]::NewGuid().ToString('N'))' />`n"
    $newContent = $content -replace '</Grid>', "$buttonXaml</Grid>"
    $newContent | Out-File -Encoding utf8 $XamlFile
    Write-Host "按钮已成功添加。"
}

#endregion

#region 生成流程入口：集成至 MSBuild 之前的自动化命令

function Invoke-DSLGeneration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DslScriptPath = ".\ui.ps1"
    )

    Write-Host "==================== 开始 DSL 生成流程 ===================="

    # 1. 清除默认 VS 提供的文件
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

    Write-Host "==================== DSL 生成流程完成 ===================="
}

#endregion

#region 模块导出

Export-ModuleMember -Function Clear-DefaultFiles, Ensure-GeneratedFolder, New-WinUIWindow, Add-UIButton, Invoke-DSLGeneration

#endregion