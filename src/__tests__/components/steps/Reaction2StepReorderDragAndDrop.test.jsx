import {
  mockReactDndDropSpecs,
  mockUpdateProcessStepPosition,
  reaction2ProcessWithSteps,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

describe("reaction 2 ProcessStep drag and drop reordering", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("reorders multiple ProcessSteps by dropping one step onto another", () => {
    renderReaction2Steps({
      reactionProcess: reaction2ProcessWithSteps([
        "Charge reagents",
        "Heat reaction",
        "Cool reaction",
      ]),
    });

    const stepDropSpecs = mockReactDndDropSpecs.filter((spec) => spec.accept === "step");
    expect(stepDropSpecs).toHaveLength(3);

    stepDropSpecs[2].drop({
      processStep: {
        id: "reaction-2-step-1",
      },
    });

    expect(mockUpdateProcessStepPosition).toHaveBeenCalledWith(
      "reaction-2-step-1",
      2
    );
  });

  test("submits the current position when a ProcessStep is dropped onto itself", () => {
    renderReaction2Steps({
      reactionProcess: reaction2ProcessWithSteps([
        "Charge reagents",
        "Heat reaction",
        "Cool reaction",
      ]),
    });

    const stepDropSpecs = mockReactDndDropSpecs.filter((spec) => spec.accept === "step");
    expect(stepDropSpecs).toHaveLength(3);

    stepDropSpecs[0].drop({
      processStep: {
        id: "reaction-2-step-1",
      },
    });

    expect(mockUpdateProcessStepPosition).toHaveBeenCalledWith(
      "reaction-2-step-1",
      0
    );
  });
});
