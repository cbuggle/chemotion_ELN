import React from 'react'

import MetricsDecorator from '../../../../../decorators/MetricsDecorator';
import StringDecorator from '../../../../../decorators/StringDecorator';

import VesselableDecorator from '../../../../../decorators/VesselableDecorator';

import InfoLinesBox from './InfoLinesBox';

const SaveInfo = ({ activity }) => {
	let sample = activity.sample

	let infoTitle = StringDecorator.toLabelSpelling(sample?.intermediate_type) + " " + (sample?.short_label || "no Label") ;

	let infoLines = []
	infoLines.push(sample?.description);

	if (sample?.target_amount) {
		infoLines.push(MetricsDecorator.infoLineAmount(sample.target_amount));
	}

	infoLines.push(VesselableDecorator.vesselableSingleLine(activity.reaction_process_vessel?.vesselable));
	infoLines.push(sample?.location);

	return (
		<InfoLinesBox title={infoTitle} lines={infoLines} />
	)
}

export default SaveInfo
