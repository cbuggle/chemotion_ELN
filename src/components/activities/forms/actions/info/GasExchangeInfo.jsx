import React, { useContext } from 'react'

import InfoLinesBox from './InfoLinesBox';

import OptionsDecorator from '../../../../../decorators/OptionsDecorator';

import { SelectOptions } from "../../../../../contexts/SelectOptions";

const GasExchangeInfo = ({ activity }) => {
	const selectOptions = useContext(SelectOptions);
	const workup = activity.workup;

	const gasOptions = selectOptions.ontologies.flatMap((ontology) => ontology.mobile_phase || []);
	const gasValues = (workup.gas_type || []).map((gas) => gas.value || gas);

	const gasLabels = gasValues.map((gasValue) => (
		OptionsDecorator.valueToLabel(gasValue, gasOptions) || gasValue
	));

	return (
		<InfoLinesBox title={gasLabels.join(', ')} />
	)
}

export default GasExchangeInfo
