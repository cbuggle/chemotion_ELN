import AutomationControlDecorator from "../../decorators/AutomationControlDecorator";

describe("AutomationControlDecorator", () => {
  test("identifies action forms with automation-mode-specific fields", () => {
    expect(AutomationControlDecorator.formDependsOnAutomationMode("CHROMATOGRAPHY")).toBe(true);
    expect(AutomationControlDecorator.formDependsOnAutomationMode("TRANSFER")).toBe(false);
  });

  test("returns automation status definitions and next statuses", () => {
    const canRun = AutomationControlDecorator.automationStatusByName("CAN_RUN");

    expect(canRun).toEqual(AutomationControlDecorator.defaultAutomationStatus);
    expect(AutomationControlDecorator.nextAutomationStatus(canRun)).toEqual(
      AutomationControlDecorator.automation_status.HALT
    );
    expect(AutomationControlDecorator.automationStatusByName("STEP_CAN_RUN")).toEqual(
      AutomationControlDecorator.defaultStepAutomationStatus
    );
  });

  test("builds dependency controls for transfers", () => {
    expect(AutomationControlDecorator.automationControlForTransferFromStepId(7)).toEqual({
      status: "DEPENDS_ON_STEP",
      depends_on_step_id: 7
    });

    expect(
      AutomationControlDecorator.automationControlForTransferFromSampleId("sample-1", [
        { id: 10, saved_sample_id: "sample-1" }
      ])
    ).toEqual({
      status: "DEPENDS_ON_ACTION",
      depends_on_action_id: 10
    });
  });
});
