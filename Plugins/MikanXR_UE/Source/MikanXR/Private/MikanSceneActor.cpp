#include "MikanSceneActor.h"
#include "MikanAnchorActor.h"
#include "MikanAnchorTypes.h"
#include "MikanTransformActor.h"
#include "MikanSceneTypes.h"
#include "MikanBoxShapeActor.h"
#include "MikanBoxStencilActor.h"
#include "MikanDataStore.h"
#include "MikanEngineSubsystem.h"
#include "MikanMath.h"
#include "MikanModelShapeActor.h"
#include "MikanModelStencilActor.h"
#include "MikanQuadShapeActor.h"
#include "MikanQuadStencilActor.h"
#include "MikanShapeTypes.h"
#include "MikanStencilActor.h"
#include "MikanStencilTypes.h"
#include "MikanClient.h"
#include "MikanAPI.h"
#include "Engine/World.h"

// -- UMikanSceneData -----
void UMikanSceneData::Initialize(const Serialization::PolymorphicObjectPtr& InValuesObject)
{
	UMikanTransformData::Initialize(InValuesObject);

	const auto* SceneValues = InValuesObject.getTypedPointer<MikanSceneComponentValues>();
	CameraId = SceneValues->camera_id;
	LightEnvironmentId = SceneValues->light_environment_id;
	LightingPresetId = SceneValues->lighting_preset_id;
	bForceRender = SceneValues->force_render;
}

bool UMikanSceneData::ApplyMikanValue(const FString& FieldName, const MikanVariant& FieldValue)
{
	if (FieldName == "parent_stage_id")
	{
		ParentStageId = FieldValue.getIntValue();
		return true;
	}
	else if (FieldName == "camera_id")
	{
		CameraId = FieldValue.getIntValue();
		return true;
	}
	else if (FieldName == "light_environment_id")
	{
		LightEnvironmentId = FieldValue.getIntValue();
		return true;
	}
	else if (FieldName == "lighting_preset_id")
	{
		LightingPresetId = FieldValue.getIntValue();
		return true;
	}
	else if (FieldName == "force_render")
	{
		bForceRender = FieldValue.getBoolValue();
		return true;
	}
	else
	{
		return UMikanTransformData::ApplyMikanValue(FieldName, FieldValue);
	}
}

void UMikanSceneData::Describe(TArray<FString>& OutLines) const
{
	UMikanTransformData::Describe(OutLines);
	Mikan::AppendDescribeLine(OutLines, TEXT("parent_stage_id"), ParentStageId);
	Mikan::AppendDescribeLine(OutLines, TEXT("camera_id"), CameraId);
	Mikan::AppendDescribeLine(OutLines, TEXT("light_environment_id"), LightEnvironmentId);
	Mikan::AppendDescribeLine(OutLines, TEXT("lighting_preset_id"), LightingPresetId);
	Mikan::AppendDescribeLine(OutLines, TEXT("force_render"), bForceRender);
}

// -- UMikanSceneSystemData -----
void UMikanSceneSystemData::Initialize(const Serialization::PolymorphicObjectPtr& InValuesObject)
{
	const auto* SystemValues = InValuesObject.getTypedPointer<MikanSceneSystemValues>();
	if (SystemValues)
	{
		CurrentSceneId = SystemValues->current_scene_id;
	}
}

bool UMikanSceneSystemData::ApplyMikanValue(const FString& FieldName, const MikanVariant& FieldValue)
{
	if (FieldName == "current_scene_id")
	{
		CurrentSceneId = FieldValue.getIntValue();
		return true;
	}

	return UMikanSystemData::ApplyMikanValue(FieldName, FieldValue);
}

void UMikanSceneSystemData::Describe(TArray<FString>& OutLines) const
{
	Mikan::AppendDescribeLine(OutLines, TEXT("current_scene_id"), CurrentSceneId);
}

// -- UMikanSceneActor -----
AMikanSceneActor::AMikanSceneActor(const FObjectInitializer& ObjectInitializer) 
	: Super(ObjectInitializer)
{
}

void AMikanSceneActor::PostRegisterAllComponents()
{
	Super::PostRegisterAllComponents();

	AMikanClient* MikanClient = GetOwnerMikanClient();
	if (MikanClient)
	{
		if (!MikanClient->OnScriptMessage.IsAlreadyBound(this, &AMikanSceneActor::OnMikanScriptMessage))
		{
			MikanClient->OnScriptMessage.AddDynamic(this, &AMikanSceneActor::OnMikanScriptMessage);
		}
	}
}

void AMikanSceneActor::Destroyed()
{
	AMikanClient* MikanClient = GetOwnerMikanClient();
	if (MikanClient)
	{
		MikanClient->OnScriptMessage.RemoveDynamic(this, &AMikanSceneActor::OnMikanScriptMessage);
	}

	Super::Destroyed();
}

// Scene Events
void AMikanSceneActor::HandleSceneActivated()
{
	OnSceneActivated();
}

void AMikanSceneActor::HandleSceneDeactivated()
{
	OnSceneDeactivated();
}

// Script Message Events
void AMikanSceneActor::HandleScriptMessage(const FString& Message)
{
	OnMikanScriptMessage(Message);
}

void AMikanSceneActor::SetSceneSubtreeHidden(bool bNewHidden)
{
	SetActorHiddenInGame(bNewHidden);

	TArray<AActor*> AttachedActors;
	GetAttachedActors(AttachedActors, /*bResetArray*/ true, /*bRecursivelyIncludeAttachedActors*/ true);
	for (AActor* AttachedActor : AttachedActors)
	{
		if (AttachedActor)
		{
			AttachedActor->SetActorHiddenInGame(bNewHidden);
		}
	}
}

void AMikanSceneActor::OnComponentDataChanged(const FString& FieldName)
{
	Super::OnComponentDataChanged(FieldName);

	// The flag decides whether this scene draws while another one is active, so the
	// client re-evaluates every scene rather than just this one
	if (FieldName == "force_render")
	{
		if (AMikanClient* MikanClient = GetOwnerMikanClient())
		{
			MikanClient->RefreshSceneVisibility();
		}
	}
}
