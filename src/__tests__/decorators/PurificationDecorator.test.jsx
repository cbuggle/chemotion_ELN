import PurificationDecorator from "../../decorators/PurificationDecorator";

describe("PurificationDecorator", () => {
  test("formats purification step details", () => {
    expect(
      PurificationDecorator.purificationStepInfo({
        amount: { value: 10, unit: "ml" },
        solvents: [
          { label: "Water", ratio: 1 },
          { label: "Ethyl acetate", ratio: 2 }
        ],
        step_mode: "GRADIENT",
        prod_mode: "COLLECT",
        repetitions: { value: 3 }
      })
    ).toBe("10 ml Water, Ethyl acetate (1:2) (Gradient) (prod: Collect) (3 Repetitions)");
  });

  test("formats solvent lines", () => {
    expect(
      PurificationDecorator.infoLineSolvents([
        { label: "Water" },
        { label: "Ethyl acetate" }
      ])
    ).toBe("Water, Ethyl acetate");

    expect(
      PurificationDecorator.infoLineSolventsWithRatio({
        amount: { value: 5, unit: "ml" },
        solvents: [
          { label: "A", ratio: 1 },
          { label: "B", ratio: 4 }
        ]
      })
    ).toBe("5 ml A,B (1:4)");
  });

  test("formats purification solvent lines for activities", () => {
    expect(
      PurificationDecorator.infoLinePurificationSolvents({
        activity_name: "CHROMATOGRAPHY",
        workup: {
          purification_steps: [
            {
              amount: { value: 5, unit: "ml" },
              solvents: [{ label: "A", ratio: 1 }]
            },
            {
              amount: { value: 10, unit: "ml" },
              solvents: [{ label: "B", ratio: 1 }]
            }
          ]
        }
      })
    ).toEqual(["Step 1", "5 ml A ", "Step 2", "10 ml B "]);
  });
});
