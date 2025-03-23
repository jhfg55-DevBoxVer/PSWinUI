# ��ȡ��ǰģ��Ŀ¼��������ײ� DLL ������·��
$moduleRoot = $PSScriptRoot
$assemblyPath = Join-Path $moduleRoot "PSWinUI.Core.dll"

if (-not (Test-Path $assemblyPath)) {
    Write-Error "ȱ�� PSWinUI.Core.dll�����ȱ��� C# ��Ŀ������ DLL ���õ�ģ��Ŀ¼�С�"
    return
}

# ���صײ� C# ����
[void][System.Reflection.Assembly]::LoadFrom($assemblyPath)

function New-PSWinUIWindow {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Title = "PSWinUI Window",

        [Parameter(Position = 1)]
        [string]$Message = "Hello from PSWinUI!"
    )
    
    # ���� C# �ײ㷽������������
    [PSWinUI.Core.WinUIAppWrapper]::ShowWindow($Title, $Message)
}

# ���� Cmdlet
Export-ModuleMember -Function New-PSWinUIWindow