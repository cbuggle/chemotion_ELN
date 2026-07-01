import React, { useContext } from "react";
import Select from "react-select";

import AmountInputSet from "../../../utilities/AmountInputSet";
import FormSection from "../../../utilities/FormSection";
import SingleLineFormGroup from "../formgroups/SingleLineFormGroup";
import VesselableFormSection from "../../../vesselables/VesselableFormSection";

import OptionsDecorator from "../../../../decorators/OptionsDecorator";

import { SelectOptions } from "../../../../contexts/SelectOptions";

const MergeSamplesForm = ({
	workup,
	onWorkupChange,
	reactionProcessVessel,
	onChangeVessel,
}) => {
	const sampleOptions = useContext(SelectOptions).materials.SAMPLE;

	const handleWorkupChange = (name) => (selected) => { onWorkupChange({ name, value: selected?.value }); };

	const selectedSample = (sampleId) => sampleOptions.find((sample) => sample.value === sampleId);

	const handleChangeAmount = (amount) => onWorkupChange({ name: "target_amount", value: amount })

	const currentSample = OptionsDecorator.optionForValue(workup['target_sample_id'], sampleOptions)

	console.log(workup)

	return (
		<>
			<VesselableFormSection
				onChange={onChangeVessel}
				reactionProcessVessel={reactionProcessVessel}
				automationMode={workup.automation_mode}
			/>
			<FormSection type="action">
				<SingleLineFormGroup label="Source Sample">
					<Select
						className="react-select--overwrite"
						classNamePrefix="react-select"
						name="source_sample_id"
						options={sampleOptions}
						value={selectedSample(workup.source_sample_id)}
						isDisabled
					/>
				</SingleLineFormGroup>
				<SingleLineFormGroup label="Target Sample ">
					<Select
						className="react-select--overwrite"
						classNamePrefix="react-select"
						name="target_sample_id"
						options={sampleOptions}
						value={selectedSample(workup.target_sample_id)}
						isDisabled
					/>
				</SingleLineFormGroup>
				<AmountInputSet
					amount={workup['target_amount']}
					maxAmounts={currentSample?.unit_amounts}
					onChangeAmount={handleChangeAmount}
				/>
			</FormSection>
		</>
	);
};

export default MergeSamplesForm;
