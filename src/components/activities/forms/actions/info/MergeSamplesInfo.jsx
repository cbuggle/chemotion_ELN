import React, { useContext } from 'react'

import InfoLinesBox from './InfoLinesBox';

import { SelectOptions } from "../../../../../contexts/SelectOptions";

const MergeSamplesInfo = ({ activity }) => {
	const selectOptions = useContext(SelectOptions);
	const sampleOptions = selectOptions.materials.SAMPLE;

	console.log("sample options")
	console.log(sampleOptions)

	const workup = activity.workup;

	const sourceSampleId = workup.source_sample_id
	const targetSampleId = workup.target_sample_id

	const sampleName = (sampleId) => {
		const sample = sampleOptions.find((option) => option.value === sampleId);
		return sample?.label || sample?.name || sampleId || 'Unknown sample';
	};

	const infoTitle = `${sampleName(sourceSampleId)} -> ${sampleName(targetSampleId)}`;

	return (
		<InfoLinesBox title={infoTitle} />
	)
}

export default MergeSamplesInfo
