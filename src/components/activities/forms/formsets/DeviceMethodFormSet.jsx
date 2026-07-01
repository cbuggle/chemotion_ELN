import React, { useContext } from 'react'

import OntologySelectFormGroup from '../formgroups/OntologySelectFormGroup';

import OptionsDecorator from '../../../../decorators/OptionsDecorator';

import { SelectOptions } from '../../../../contexts/SelectOptions';

const DeviceMethodFormSet = ({
	activity,
	onWorkupChange,
}) => {
	let ontologies = useContext(SelectOptions).ontologies
	let workup = activity.workup

	const handleChangeType = (newType) => {
		if (newType?.value !== workup.type) {
			onWorkupChange({ name: 'type', value: newType?.value })
			handleChangeSubType({ value: undefined })
		}
	}

	const handleChangeSubType = (newSubType) => {
		if (newSubType?.value !== workup.subtype) {
			onWorkupChange({ name: 'subtype', value: newSubType?.value })
			handleChangeDevice({ value: undefined })
		}
	}

	const handleChangeDevice = (device) => {
		onWorkupChange({ name: 'device', value: device?.value })
		if (device?.value !== workup.device) { handleChangeMethod(undefined) }
	}

	const handleChangeMethod = (method) => {
		onWorkupChange({ name: 'method', value: method?.value })
	}
	const currentDeviceOption = OptionsDecorator.inclusiveOptionForValue(workup.device, ontologies)

	const requiresTypeSubtypeForm = ['ADD', 'TRANSFER', 'MERGE_SAMPLES', 'MIXING'].includes(activity.activity_name)

	return (
		<>
			{requiresTypeSubtypeForm && <>
				<OntologySelectFormGroup
					key={"type" + workup.type}
					roleName={'type'}
					workup={workup}
					onChange={handleChangeType}
				/>
				<OntologySelectFormGroup
					key={"subtype" + workup.subtype + "type" + workup.type}
					roleName={'subtype'}
					workup={workup}
					onChange={handleChangeSubType}
				/>
			</>
			}

			<OntologySelectFormGroup
				key={"device" + workup.device}
				roleName={'device'}
				workup={workup}
				onChange={handleChangeDevice}
			/>
			<OntologySelectFormGroup
				key={"method" + workup.method}
				roleName={'method'}
				workup={workup}
				options={currentDeviceOption?.methods}
				onChange={handleChangeMethod}
			/>
		</>
	);
};

export default DeviceMethodFormSet
