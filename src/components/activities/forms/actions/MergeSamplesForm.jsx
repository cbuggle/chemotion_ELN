import React from 'react'
import MetricsInputFormGroup from '../formgroups/MetricsInputFormGroup'

const MixingForm = ({ workup, onWorkupChange }) => {

	const handleWorkupChange = (name) => (value) => {
		onWorkupChange({ name: name, value: value });
	}

	return (
		<>
			<MetricsInputFormGroup
				key={'SPEED'}
				metricName={'SPEED'}
				amount={workup.speed}
				onChange={handleWorkupChange('speed')}
			/>
		</>
	)
}

export default MixingForm
