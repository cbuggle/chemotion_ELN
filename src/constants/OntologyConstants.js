
import StringDecorator from "../decorators/StringDecorator"

export const OntologyConstants = {
	class:
	{
		ADD: 'OBI:0000274',
		TRANSFER: 'OBI:0000383',
		CENTRIFUGATION: 'OBI:0302886',
		CHROMATOGRAPHY: 'CHMO:0001000',
		CRYSTALLISATION: 'CHMO:0001477',
		EXTRACTION: 'CHMO:0001577',
		FILTRATION: 'CHMO:0001640',
		MIXING: 'CHMO:0001685',
		ANALYSIS_CHROMATOGRAPHY: 'CHMO:0001000',
		ANALYSIS_ELEMENTAL: 'CHMO:0001075',
		ANALYSIS_SPECTROSCOPY: 'CHMO:0000228',
		EVAPORATION: 'CHMO:0001574',
		GAS_EXCHANGE: 'NCIT:C171981',
		MERGE_SAMPLES: 'OBI:0000652',
	},
	automation_mode: {
		manual: "NCIT:C63513",
		semiAutomated: "NCIT:C172484",
		automated: "NCIT:C70669"
	},

	isAutomated: (status => status === OntologyConstants.automation_mode.automated),
	isSemiAutomated: (status => status === OntologyConstants.automation_mode.semiAutomated),
	isManual: (status => status === OntologyConstants.automation_mode.manual),

	ontologyTypeOptions: ['TERMINOLOGY', 'CUSTOM_TERMINOLOGY', 'DEVICE_TYPE', 'DEVICE_CONFIG'].map((ont) => { return { value: ont, label: StringDecorator.toLabelSpelling(ont)}}),

	roleTypeOptions: ["action", "class", "type", "subtype", "detector", "condition", "device", "solvent", "mobile_phase", "material", "automation_mode"].map(i => { return { value: i, label: StringDecorator.toLabelSpelling(i) } }),

	isDevice: (type => ['DEVICE_TYPE', 'DEVICE_CONFIG'].includes(type))
}
