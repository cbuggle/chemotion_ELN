import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import { OntologyConstants } from "../../../constants/OntologyConstants";
import {
  mockUpdateProcessStep,
  reaction2Process,
  reaction2Step,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

const automationModes = [
  { label: "manual", value: OntologyConstants.automation_mode.manual },
  { label: "semi-automated", value: OntologyConstants.automation_mode.semiAutomated },
  { label: "automated", value: OntologyConstants.automation_mode.automated },
];

const reaction2ProcessWithMode = (automationMode) => ({
  ...reaction2Process,
  reaction_process_steps: [
    reaction2Step("Tune automation", 0, {
      automation_mode: automationMode,
      final_conditions: {
        ...reaction2Process.initial_conditions,
        automation_mode: automationMode,
      },
    }),
  ],
});

const openStepForm = (container) => {
  userEvent.click(container.querySelector(".procedure-card--step button[aria-label='pen']"));
};

const openNewActionForm = ({ buttonName, buttonIndex = 0 }) => {
  userEvent.click(screen.getByRole("button", { name: "New Action" }));
  userEvent.click(screen.getAllByRole("button", { name: buttonName })[buttonIndex]);
};

const renderActionFormForMode = ({ automationMode, buttonName, buttonIndex }) => {
  const renderResult = renderReaction2Steps({
    reactionProcess: reaction2ProcessWithMode(automationMode),
  });

  openNewActionForm({ buttonName, buttonIndex });

  return renderResult;
};

const expectChromatographyManualFields = () => {
  expect(screen.getByLabelText("material")).toBeInTheDocument();
  expect(screen.getByText("Stationary Phase")).toBeInTheDocument();
  expect(screen.queryByLabelText("device")).not.toBeInTheDocument();
  expect(screen.queryByLabelText("method")).not.toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Chromatography Step" })).toBeInTheDocument();
};

const expectChromatographySemiAutomatedFields = () => {
  expect(screen.getByLabelText("device")).toBeInTheDocument();
  expect(screen.getByLabelText("detector")).toBeInTheDocument();
  expect(screen.getByLabelText("mobile_phase")).toBeInTheDocument();
  expect(screen.getByLabelText("stationary_phase")).toBeInTheDocument();
  expect(screen.queryByLabelText("material")).not.toBeInTheDocument();
  expect(screen.queryByLabelText("method")).not.toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Chromatography Step" })).toBeInTheDocument();
};

const expectChromatographyAutomatedFields = () => {
  expect(screen.getByLabelText("device")).toBeInTheDocument();
  expect(screen.getByLabelText("detector")).toBeInTheDocument();
  expect(screen.getByLabelText("mobile_phase")).toBeInTheDocument();
  expect(screen.getByLabelText("method")).toBeInTheDocument();
  expect(screen.queryByLabelText("material")).not.toBeInTheDocument();
  expect(screen.queryByLabelText("stationary_phase")).not.toBeInTheDocument();
  expect(screen.queryByRole("button", { name: "Chromatography Step" })).not.toBeInTheDocument();
};

describe("reaction 2 step automation mode", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test.each(automationModes)("sets step automation mode to $label", async (mode) => {
    const { container } = renderReaction2Steps({
      reactionProcess: reaction2ProcessWithMode(OntologyConstants.automation_mode.automated),
    });

    openStepForm(container);
    userEvent.click(screen.getByRole("button", { name: mode.label }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateProcessStep).toHaveBeenCalledTimes(1));
    expect(mockUpdateProcessStep).toHaveBeenCalledWith(
      expect.objectContaining({
        id: "reaction-2-step-1",
        automation_mode: mode.value,
      })
    );
  });

  test.each([
    {
      label: "manual",
      automationMode: OntologyConstants.automation_mode.manual,
      expectFields: expectChromatographyManualFields,
    },
    {
      label: "semi-automated",
      automationMode: OntologyConstants.automation_mode.semiAutomated,
      expectFields: expectChromatographySemiAutomatedFields,
    },
    {
      label: "automated",
      automationMode: OntologyConstants.automation_mode.automated,
      expectFields: expectChromatographyAutomatedFields,
    },
  ])("renders purification Chromatography fields for $label step mode", ({ automationMode, expectFields }) => {
    renderActionFormForMode({
      automationMode,
      buttonName: "Chromatography",
      buttonIndex: 1,
    });

    expectFields();
  });

  test.each([
    {
      label: "manual",
      automationMode: OntologyConstants.automation_mode.manual,
      expectFields: expectChromatographyManualFields,
    },
    {
      label: "semi-automated",
      automationMode: OntologyConstants.automation_mode.semiAutomated,
      expectFields: expectChromatographySemiAutomatedFields,
    },
    {
      label: "automated",
      automationMode: OntologyConstants.automation_mode.automated,
      expectFields: expectChromatographyAutomatedFields,
    },
  ])("renders analysis Chromatography fields for $label step mode", ({ automationMode, expectFields }) => {
    renderActionFormForMode({
      automationMode,
      buttonName: "Chromatography",
      buttonIndex: 0,
    });

    expectFields();
  });
});
