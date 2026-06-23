import ActivityInfoDecorator from "../../decorators/ActivityInfoDecorator";

const selectOptions = {
  equipment: [
    { value: "stirrer", label: "Stirrer" },
    { value: "bath", label: "Oil Bath" }
  ],
  FORMS: {
    MOTION: {
      motion_types: [{ value: "STIRRING", label: "Stirring" }],
      motion_modes: [{ value: "MAGNETIC", label: "Magnetic" }]
    }
  }
};

describe("ActivityInfoDecorator", () => {
  test("builds activity card titles", () => {
    expect(ActivityInfoDecorator.cardTitle({ activity_name: "TRANSFER", workup: {} })).toBe("Transfer");
    expect(
      ActivityInfoDecorator.cardTitle({
        activity_name: "ADD",
        workup: { acts_as: "SOLVENT", sample_name: "Water" }
      })
    ).toBe("Add Solvent: Water");
    expect(
      ActivityInfoDecorator.cardTitle({
        activity_name: "ADD",
        workup: { target_amount: { value: 1, unit: "ml" } }
      })
    ).toBe("Add  Chemical");
    expect(
      ActivityInfoDecorator.cardTitle({
        activity_name: "SAVE",
        workup: { short_label: "F1" }
      })
    ).toBe("Save F1");
    expect(
      ActivityInfoDecorator.cardTitle({
        activity_name: "CONDITION",
        workup: { TEMPERATURE: { value: 20, unit: "CELSIUS" } }
      })
    ).toBe("Change Condition");
  });

  test("formats equipment condition summaries", () => {
    expect(
      ActivityInfoDecorator.conditionInfo(
        "EQUIPMENT",
        { value: ["stirrer", "bath"] },
        undefined,
        selectOptions
      )
    ).toBe("Stirrer, Oil Bath");
  });

  test("formats motion condition summaries", () => {
    expect(
      ActivityInfoDecorator.conditionInfo(
        "MOTION",
        {
          motion_type: "STIRRING",
          motion_mode: "MAGNETIC",
          speed: { value: 800, unit: "RPM" }
        },
        undefined,
        selectOptions
      )
    ).toBe("Stirring Magnetic 800 rpm");
  });

  test("formats amount conditions with deltas", () => {
    expect(
      ActivityInfoDecorator.conditionInfo(
        "TEMPERATURE",
        { value: 30, unit: "CELSIUS" },
        { value: 20, unit: "CELSIUS" },
        selectOptions
      )
    ).toBe("30 \u00b0C (+10)");
  });

  test("formats wavelengths", () => {
    expect(
      ActivityInfoDecorator.infoLineWavelengths({
        is_range: true,
        peaks: [{ value: 220 }, { value: 280 }]
      })
    ).toBe("Range 220 - 280 nm");

    expect(
      ActivityInfoDecorator.infoLineWavelengths({
        is_range: false,
        peaks: [{ value: 220 }, { value: 254 }, { value: 280 }]
      })
    ).toBe("220, 254, 280");
  });

  test("joins sample condition lines and remove conditions", () => {
    expect(
      ActivityInfoDecorator.infoLineSampleCondition({
        TEMPERATURE: { value: 20, unit: "CELSIUS" },
        PRESSURE: { value: 1000, unit: "MBAR" }
      })
    ).toBe("20 \u00b0C, 1000 mbar");

    expect(
      ActivityInfoDecorator.infoLineRemoveConditions({
        TEMPERATURE: { value: 20, unit: "CELSIUS" },
        PRESSURE: { value: 1000, unit: "MBAR" },
        duration: 65000
      })
    ).toBe("20 \u00b0C, 1000 mbar, 1min 5s");
  });
});
