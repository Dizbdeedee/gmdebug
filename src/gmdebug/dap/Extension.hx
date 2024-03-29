package gmdebug.dap;

import vscode.WorkspaceFolder;
import vscode.DebugConfiguration;
import vscode.CancellationToken;
import Vscode;
import vscode.DebugAdapterExecutable;
import vscode.DebugAdapterInlineImplementation;
import vscode.ProviderResult;
import vscode.DebugAdapterDescriptorFactory;
import vscode.Uri;

using tink.CoreApi;
using Lambda;

class Extension {
	@:expose("activate")
	static function activate(context:vscode.ExtensionContext) {
		trace("gmdebug activated");

		Vscode.commands.registerCommand("extension.gmdebug.FilePicker", (config) -> {
			final selectedFolderP = Vscode.window.showOpenDialog({
				canSelectFiles: false,
				canSelectFolders: true,
			});
			return selectedFolderP.then((arr) -> {
				return arr[0].toString();
			});
		});

		final fact:DebugAdapterDescriptorFactory = new InlineDebugAdapterProvide();
		context.subscriptions.push(Vscode.debug.registerDebugAdapterDescriptorFactory("gmdebug", fact));
		final provider = new MockConfigurationProvider();
		context.subscriptions.push(Vscode.debug.registerDebugConfigurationProvider('gmdebug', provider));
	}

	@:expose("deactivate")
	static function deactivate() {}

	@:expose("runMode")
	static var runMode = "inline";
}

private class DebugConfigProvider {
	public var resolveDebugConfiguration = null;

	public var resolveDebugConfigurationWithSubstitutedVariables = null;

	public function new() {}
}

private class InlineDebugAdapterProvide {
	public function createDebugAdapterDescriptor(session:vscode.DebugSession,
			?executable:DebugAdapterExecutable):ProviderResult<vscode.DebugAdapterDescriptor> {
		return cast new DebugAdapterInlineImplementation(cast new LuaDebugger(null, null
			, session.workspaceFolder.uri.fsPath));
	}

	public function new() {}
}

private class MockConfigurationProvider {
	public function new() {}

	public var provideDebugConfigurations = null;

	public var resolveDebugConfigurationWithSubstitutedVariables = null;

	/**
	 * Massage a debug configuration just before a debug session is being launched,
	 * e.g. add all missing attributes to the debug configuration.
	 */
	public function resolveDebugConfiguration(folder:Null<WorkspaceFolder>,
			debugConfiguration:DebugConfiguration,
			?token:CancellationToken):ProviderResult<DebugConfiguration> {
		trace('THE FOLDER $folder');
		return debugConfiguration;
	}
}
