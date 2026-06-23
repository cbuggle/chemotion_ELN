import MetricsDecorator from "../../decorators/MetricsDecorator";

describe("MetricsDecorator", () => {
  test("returns metric metadata", () => {
    expect(MetricsDecorator.label("VOLUME")).toBe("Volume");
    expect(MetricsDecorator.units("VOLUME")).toEqual(["mcl", "ml", "l"]);
    expect(MetricsDecorator.defaultUnit("VOLUME")).toBe("ml");
    expect(MetricsDecorator.analysisTypeLabel("VOLUME")).toBe("volumetric");
  });

  test("builds default amounts from the metric default unit", () => {
    expect(MetricsDecorator.defaultAmount("VOLUME")).toEqual({
      value: 10,
      unit: "ml"
    });
  });

  test("finds the base unit for a supported unit", () => {
    expect(MetricsDecorator.baseUnit("l")).toBe("ml");
    expect(MetricsDecorator.baseUnit("g")).toBe("mg");
  });

  test("formats amounts, including zero values", () => {
    expect(MetricsDecorator.infoAmount({ value: 12.3456789012345, unit: "ml" })).toBe("12.3456789012 ml");
    expect(MetricsDecorator.infoAmount({ value: 0, unit: "mg" })).toBe("0 mg");
  });

  test("falls back when an amount is unspecified", () => {
    expect(MetricsDecorator.infoLineAmount(undefined)).toBe("Unspecified Amount");
    expect(MetricsDecorator.infoLineAmount({ unit: "ml" })).toBe("Unspecified Amount");
  });

  test("formats percentage and delta annotations", () => {
    expect(
      MetricsDecorator.infoLineAmountWithPercentage({
        value: 5,
        unit: "ml",
        percentage: 33.333
      })
    ).toBe("5 ml (33.3%)");

    expect(
      MetricsDecorator.infoLineAmountWithDelta(
        { value: 25, unit: "CELSIUS" },
        { value: 20, unit: "CELSIUS" }
      )
    ).toBe("25 \u00b0C (+5)");
  });

  test("calculates overscaled amounts", () => {
    expect(MetricsDecorator.overscaledAmount(10)).toBe(12);
  });
});
