using UnrealBuildTool;

public class MikanXRTestAppTarget : TargetRules
{
	public MikanXRTestAppTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Game;
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;

		ExtraModuleNames.Add("MikanXRTestApp");
	}
}
