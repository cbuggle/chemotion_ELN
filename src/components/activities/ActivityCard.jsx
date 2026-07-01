import React, { useContext, useState } from "react";

import ActionForm from "./forms/actions/ActionForm";
import ActivityInfoDecorator from "../../decorators/ActivityInfoDecorator";
import ActivityInfo from "./ActivityInfo";
import ConditionForm from "./forms/conditions/ConditionForm";
import ProcedureCard from "../utilities/ProcedureCard";
import ActionTypeSelectionPanel from "../utilities/ActionTypeSelectionPanel";
import Timer from "./timing/Timer";

import { useReactionsFetcher } from "../../fetchers/ReactionsFetcher";
import { SubFormController } from "../../contexts/SubFormController";
import { StepLock } from "../../contexts/StepLock";
import { useActivityValidator } from "../../validators/ActivityValidator";
import IconButton from "../utilities/IconButton";

import { tooltips } from "../../constants/translations";

import { UncontrolledTooltip } from "reactstrap";
import AutomationControlDecorator from "../../decorators/AutomationControlDecorator";

const ActivityCard = ({
  type,
  activity,
  onSave,
  onCancel,
  preconditions,
  customClass,
  dragRef,
  forceShowForm,
  hideMoveButton,
  processStep
}) => {
  const api = useReactionsFetcher();
  const subFormController = useContext(SubFormController);
  const stepLock = useContext(StepLock);
  const activityValidator = useActivityValidator();

  const isInitialised = !!activity;

  const isCondition = type === "condition";
  const formDependsOnAutomationMode = AutomationControlDecorator.formDependsOnAutomationMode(activity?.activity_name)

  const workup = isInitialised ? activity.workup : {}

  const currentAutomationStatus = AutomationControlDecorator.automationStatusByName(workup.automation_control?.status) || AutomationControlDecorator.defaultAutomationStatus

  const automationModeMismatch = processStep && workup.automation_mode !== processStep?.automation_mode

  const uninitialisedForm = isCondition ? { activity_name: "CONDITION", workup: workup } : undefined;
  const uninitialisedDisplayMode = isCondition || forceShowForm ? "form" : "type-panel";
  const uninitialisedTitle = isCondition ? "Change Condition" : "New Action";

  const [activityForm, setActivityForm] = useState(
    isInitialised ? JSON.parse(JSON.stringify(activity)) : uninitialisedForm
  );
  const [displayMode, setDisplayMode] = useState(
    isInitialised && !forceShowForm ? "info" : uninitialisedDisplayMode
  );

  const fillActivityForm = (activity) => {
    setActivityForm(structuredClone(activity))
  }

  const cardTitle = !!activityForm?.activity_name
    ? ActivityInfoDecorator.cardTitle(activityForm)
    : uninitialisedTitle;

  const isEditable = displayMode === "info" && !stepLock
  const isCanceable = displayMode !== "info" && !stepLock;

  const edit = () => setDisplayMode(isInitialised ? "form" : uninitialisedDisplayMode());

  const onDelete = () => api.deleteActivity(activity.id);

  const onSelectType = (newActivity) => () => {
    newActivity.workup ||= {}
    fillActivityForm(newActivity);
    setDisplayMode("form");
  };

  const onSaveForm = () => {
    if (activityValidator.validateActivity(activityForm)) {
      onSave(activityForm);
      subFormController.closeAllSubForms();
      if (isInitialised && !forceShowForm) {
        setDisplayMode("info");
      } else {
        fillActivityForm({ workup: {} });
      }
    }
  };

  const handleCancel = () => {
    if (isInitialised && !forceShowForm) {
      fillActivityForm(activity);
      setDisplayMode("info");
    } else {
      fillActivityForm({ workup: {} });
      onCancel();
    }
  };

  const handleWorkupChange = ({ name, value }) => {
    setActivityForm((prevState) => {
      let newWorkup = prevState.workup
      if (value === undefined) { delete newWorkup[name]; } else { newWorkup[name] = value }
      return { ...prevState, workup: newWorkup }
    })
  };

  const setDuration = (value) => handleWorkupChange({ name: "duration", value: value });

  const setVessel = (reactionProcessVessel) => {
    setActivityForm((prevState) => ({
      ...prevState,
      reaction_process_vessel: reactionProcessVessel,
    }));
  };

  const renderIconWarning = (tooltipName) => {
    return (
      <>
        <div id={"activity_automation_mode_" + activity?.id + tooltipName}>
          <IconButton
            size={"sm"}
            positive={true}
            icon={"circle-info"}
            color={"danger"} />
        </div>
        <UncontrolledTooltip target={"activity_automation_mode_" + activity?.id + tooltipName}>
          {tooltips[tooltipName]}
        </UncontrolledTooltip>
      </>
    )
  }


  console.log("activity")
  console.log(activity)
  const isMergeSamplesForm = ['MERGE_SAMPLES'].includes(activity?.activity_name)
  const samplesTypeUnspecified = !activity?.workup?.type

  const renderTitleBar = (title) => {
    return (
      <div className="d-md-flex gap-2">
        {automationModeMismatch && formDependsOnAutomationMode && renderIconWarning('action_unmet_automation_mode')}
        {isMergeSamplesForm && samplesTypeUnspecified && renderIconWarning('merge_sample_type_unspecified')}
        <div id={"activity_automation_status_" + activity?.id}>
          <IconButton
            disabled
            size={"sm"}
            positive={false}
            icon={currentAutomationStatus.icon}
            color={currentAutomationStatus.color} />
        </div>
        <UncontrolledTooltip target={"activity_automation_status_" + activity?.id} >
          {currentAutomationStatus.tooltip}
        </UncontrolledTooltip>
        {title}
      </div>
    )
  }

  return (
    <ProcedureCard
      title={renderTitleBar(cardTitle)}
      type={type}
      onEdit={edit}
      onDelete={onDelete}
      onCancel={handleCancel}
      showEditBtn={isEditable}
      showMoveBtn={isEditable && !hideMoveButton}
      showDeleteBtn={isEditable}
      showCancelBtn={isCanceable}
      displayMode={displayMode}
      headerTitleTag="h6"
      customClass={customClass}
      dragRef={dragRef}
    >
      <ProcedureCard.Info>
        <>
          <ActivityInfo activity={activity} preconditions={preconditions} />
          <Timer
            activityType={type}
            workup={activityForm?.workup}
            onSave={onSaveForm}
            onWorkupChange={handleWorkupChange}
            onChangeDuration={setDuration}
            displayMode="info"
          />
        </>
      </ProcedureCard.Info>
      <ProcedureCard.TypePanel>
        <ActionTypeSelectionPanel onSelect={onSelectType} />
      </ProcedureCard.TypePanel>
      <ProcedureCard.Form>
        {activityForm && !isCondition && (
          <ActionForm
            activity={activityForm}
            preconditions={preconditions}
            onCancel={handleCancel}
            onSave={onSaveForm}
            onWorkupChange={handleWorkupChange}
            onChangeDuration={setDuration}
            onChangeVessel={setVessel}
            processStep={processStep}
          />
        )}

        {isCondition && (
          <ConditionForm
            activity={activityForm}
            preconditions={preconditions}
            onCancel={handleCancel}
            onSave={onSaveForm}
            onWorkupChange={handleWorkupChange}
            onChangeDuration={setDuration}
          />
        )}
      </ProcedureCard.Form>
    </ProcedureCard>
  );
};

export default ActivityCard;
