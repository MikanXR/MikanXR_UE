# MikanXR_UE

The Unreal Engine plugin for [MikanXR](https://github.com/MikanXR/MikanXR), and a small test project that hosts it. The plugin connects Unreal to a running Mikan editor, mirrors the Mikan scene as actors, and publishes render targets back to Mikan's compositor. See [`Plugins/MikanXR_UE/README.md`](Plugins/MikanXR_UE/README.md) for what the plugin does and how to drive it.

## Using the plugin in your own project

1. Download `MikanXR_UE_<version>.zip` from the [releases page](https://github.com/MikanXR/MikanXR_UE/releases).
2. Extract it into your project's `Plugins` folder, so you get `Plugins/MikanXR_UE/MikanXR.uplugin`.
3. Open the project. The zip holds source, not prebuilt binaries, so the project must be a C++ project for Unreal to compile the plugin. A Blueprint-only project can be converted by adding any C++ class from the editor.
4. Place a `MikanClient` actor in your level, run Mikan, and connect from the actor's details panel.

The plugin builds against Unreal Engine 5.5 and 5.8 on Win64.

## Running the test project

You need Windows, Visual Studio 2022 with the Unreal C++ workload, and Unreal Engine 5.8 (an Epic launcher install or a source build).

1. Clone this repository.
2. Run `BindUnrealEngine.bat` and pick the engine's `Engine` folder, for example `C:\Program Files\Epic Games\UE_5.8\Engine`. You can also pass the folder as an argument. This writes `SetUnrealEngineVars_x64.bat`, which the other scripts read and git ignores.
3. Run `BuildEditor.bat`, then `LaunchEditor.bat`. `GenerateProjectFiles.bat` makes a Visual Studio solution if you want one.
4. Start Mikan. The `MikanTest` map opens with a `MikanClient` actor already placed. Connect from its details panel, or with `python Plugins/MikanXR_UE/Tools/ue_automate.py "mikan connect" "until:mikan status:connected true"`.

`BuildPlugin.bat` compiles the plugin on its own, outside the test project, the way a consumer's project builds it. Run it before a release.

## Refreshing the MikanXR client SDK

The plugin vendors the MikanXR client SDK under `Plugins/MikanXR_UE/ThirdParty/MikanXR`. To update it after a MikanXR client API change:

1. Build the client SDK in a MikanXR checkout (its `INSTALL_CLIENT_SDK` target writes `dist/ClientSDK/Win64`), or unpack a `ClientSDK` zip from a MikanXR release.
2. Run `BindMikan.bat` and pick that folder. It records the folder in `SetMikanVars_x64.bat` and runs `FetchMikan.bat`, which replaces the vendored headers, import libraries, and DLLs. Later refreshes only need `FetchMikan.bat`.

## Plugin assets and engine versions

The plugin's `Content` is saved from Unreal Engine 5.5, the oldest version the plugin supports, because an asset saved by a newer engine cannot be opened by an older one. The test project runs on 5.8, so do not save plugin assets from it. Edit them from a 5.5 editor, for example with this project bound to a 5.5 engine. Test project content under `Content/` is 5.8 only.

## Releases

Pushing a `v<major>.<minor>.<patch>` tag runs `.github/workflows/release.yml`. It stamps the version into `MikanXR.uplugin`, zips `Plugins/MikanXR_UE` without build outputs, and drafts a GitHub release with `MikanXR_UE_<version>.zip` attached. The draft is published by hand after a read. Running the workflow by hand builds the same zip as a workflow artifact without publishing anything.
