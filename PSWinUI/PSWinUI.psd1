@{
    # 模块的版本号
    ModuleVersion = '0.1.0'
    
    # 模块发布者
    Author = 'jhfg55'
    
    # 导出的组件
    FunctionsToExport = @('New-PSWinUIWindow')
    
    # DLL 文件，确保在模块加载时一并加载
    RequiredAssemblies = @('PSWinUI.Core.dll')
}