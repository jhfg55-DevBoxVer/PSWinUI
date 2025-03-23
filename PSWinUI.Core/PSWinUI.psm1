# 获取当前模块目录，并构造底层 DLL 的完整路径
$moduleRoot = $PSScriptRoot
$assemblyPath = Join-Path $moduleRoot "PSWinUI.Core.dll"

if (-not (Test-Path $assemblyPath)) {
    Write-Error "缺少 PSWinUI.Core.dll。请先编译 C# 项目，并将 DLL 放置到模块目录中。"
    return
}

# 加载底层 C# 程序集
[void][System.Reflection.Assembly]::LoadFrom($assemblyPath)

function New-PSWinUIWindow {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Title = "PSWinUI Window",

        [Parameter(Position = 1)]
        [string]$Message = "Hello from PSWinUI!"
    )
    
    # 调用 C# 底层方法以启动窗口
    [PSWinUI.Core.WinUIAppWrapper]::ShowWindow($Title, $Message)
}

# 导出 Cmdlet
Export-ModuleMember -Function New-PSWinUIWindow