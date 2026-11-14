# Debugger: nvim-dap + dap-ui. easy-dotnet registers the .NET (netcoredbg)
# adapter and launch/attach configurations itself.
{...}: {
  plugins = {
    dap.enable = true;
    dap-virtual-text.enable = true; # variable values inline, like Rider
    dap-ui.enable = true;
  };

  extraConfigLua = ''
    -- Open the debugger panels when a session starts, close them when it ends.
    do
      local dap, dapui = require('dap'), require('dapui')
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end
  '';
}
