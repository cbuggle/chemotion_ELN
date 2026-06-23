import OntologiesOptionsDecorator from "../../decorators/OntologiesOptionsDecorator";

const ontologies = [
  {
    ontology_id: "type-a",
    value: "TYPE_A",
    label: "Type A",
    active: true,
    roles: { type: [{}] }
  },
  {
    ontology_id: "subtype-a",
    value: "SUBTYPE_A",
    label: "Subtype A",
    active: true,
    roles: { subtype: [{ type: ["TYPE_A"] }] }
  },
  {
    ontology_id: "subtype-inactive",
    value: "SUBTYPE_INACTIVE",
    label: "Inactive Subtype",
    active: false,
    roles: { subtype: [{ type: ["TYPE_A"] }] }
  },
  {
    ontology_id: "detector-a",
    value: "DET_A",
    label: "Detector A",
    active: true,
    roles: { detector: [{}] }
  },
  {
    ontology_id: "device-a",
    value: "DEVICE_A",
    label: "Device A",
    active: true,
    roles: { device: [{ subtype: ["SUBTYPE_A"] }] },
    detectors: [{ value: "DET_A" }]
  }
];

describe("OntologiesOptionsDecorator", () => {
  test("finds ontology options and labels by ontology id", () => {
    expect(
      OntologiesOptionsDecorator.findByOntologyId({
        ontologyId: "type-a",
        ontologies
      })
    ).toEqual(ontologies[0]);

    expect(
      OntologiesOptionsDecorator.labelForOntologyId({
        ontologyId: "type-a",
        ontologies
      })
    ).toBe("Type A");
  });

  test("filters active options by role", () => {
    expect(
      OntologiesOptionsDecorator.activeOptionsForRoleName({
        roleName: "subtype",
        options: ontologies
      })
    ).toEqual([ontologies[1]]);
  });

  test("filters options by workup dependencies", () => {
    expect(
      OntologiesOptionsDecorator.activeOptionsForWorkupDependencies({
        roleName: "subtype",
        workup: { type: "TYPE_A" },
        ontologies
      })
    ).toEqual([ontologies[1]]);
  });

  test("keeps current missing single-value selections as unmet dependencies", () => {
    expect(
      OntologiesOptionsDecorator.selectableOptionsMatchingWorkupDependencies({
        roleName: "subtype",
        workup: { type: "OTHER", subtype: "subtype-a" },
        ontologies
      })
    ).toEqual([{ ...ontologies[1], unmetDependency: true }]);
  });

  test("keeps current missing multi-value selections as unmet dependencies", () => {
    expect(
      OntologiesOptionsDecorator.selectableMultiOptionsForWorkupDependencies({
        roleName: "detector",
        workup: { detector: ["missing-detector"] },
        ontologies
      })
    ).toEqual([
      ontologies[3],
      {
        ontology_id: "missing-detector",
        value: "missing-detector",
        label: "missing-detector",
        unavailable: true,
        roles: [],
        unmetDependency: true
      }
    ]);
  });

  test("filters devices and subtypes by selected detectors", () => {
    expect(
      OntologiesOptionsDecorator.filterDevicesByDetectors({
        workup: { detector: ["DET_A"] },
        ontologies
      })
    ).toEqual([ontologies[4]]);

    expect(
      OntologiesOptionsDecorator.filterSubtypeByDetectors({
        workup: { detector: ["DET_A"] },
        ontologies
      })
    ).toEqual([ontologies[1]]);
  });
});
