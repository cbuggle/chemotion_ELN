import React, { useContext } from "react";
import Select from "react-select";

import FormSection from "../../../utilities/FormSection";
import SingleLineFormGroup from "../formgroups/SingleLineFormGroup";
import VesselableFormSection from "../../../vesselables/VesselableFormSection";

import { SelectOptions } from "../../../../contexts/SelectOptions";

const MergeSamplesForm = ({
  workup,
  onWorkupChange,
  reactionProcessVessel,
  onChangeVessel,
}) => {
  const sampleOptions = useContext(SelectOptions).materials.SAMPLE;

  const handleWorkupChange = (name) => (selected) => {
    onWorkupChange({ name, value: selected?.value });
  };

  const selectedSample = (sampleId) => (
    sampleOptions.find((sample) => sample.value === sampleId)
  );

  return (
    <>
      <FormSection type="action">
        <VesselableFormSection
          onChange={onChangeVessel}
          reactionProcessVessel={reactionProcessVessel}
        />
      </FormSection>
      <FormSection type="action">
        <SingleLineFormGroup label="Sample 1">
          <Select
            className="react-select--overwrite"
            classNamePrefix="react-select"
            name="sample_1_id"
            options={sampleOptions}
            value={selectedSample(workup.sample_1_id)}
            onChange={handleWorkupChange("sample_1_id")}
            isClearable
          />
        </SingleLineFormGroup>
        <SingleLineFormGroup label="Sample 2">
          <Select
            className="react-select--overwrite"
            classNamePrefix="react-select"
            name="sample_2_id"
            options={sampleOptions}
            value={selectedSample(workup.sample_2_id)}
            onChange={handleWorkupChange("sample_2_id")}
            isClearable
          />
        </SingleLineFormGroup>
      </FormSection>
    </>
  );
};

export default MergeSamplesForm;
