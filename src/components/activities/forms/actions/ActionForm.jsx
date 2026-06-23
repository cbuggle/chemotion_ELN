import React, { useEffect } from 'react';

import FiltrationForm from './purification/FiltrationForm';
import ExtractionForm from './purification/ExtractionForm';
import CrystallizationForm from './purification/CrystallizationForm';
import ChromatographyForm from './purification/ChromatographyForm';
import CentrifugationForm from './purification/CentrifugationForm';

import AnalysisChromatographyForm from './analysis/AnalysisChromatographyForm';
import AnalysisElementalForm from './analysis/AnalysisElementalForm';
import AnalysisSpectroscopyForm from './analysis/AnalysisSpectroscopyForm';

import ActivityForm from "../ActivityForm";
import AddSampleForm from "./AddSampleForm";

import SaveSampleForm from "./SaveSampleForm";
import TransferForm from "./TransferForm";
import DefineFractionForm from './DefineFractionForm';
import DiscardForm from './DiscardForm';
import EvaporationForm from './EvaporationForm';
import MixingForm from './MixingForm';
import GasExchangeForm from './GasExchangeForm';
import WaitForm from './WaitForm';

import FractionFormGroup from '../formgroups/FractionFormGroup';

import DeviceMethodFormSet from '../formsets/DeviceMethodFormSet';

import { OntologyConstants } from '../../../../constants/OntologyConstants';

const ActionForm = (
  {
    activity,
    preconditions,
    onCancel,
    onSave,
    onWorkupChange,
    onChangeDuration,
    onChangeVessel,
    processStep
  }) => {

  const actionTypeName = activity.activity_name
  const workup = activity.workup

  useEffect(() => {
    let ontologyValue = OntologyConstants.class[activity.activity_name]
    onWorkupChange({ name: 'class', value: ontologyValue })

    // Ontology dependencies will be calculated by the current workout. To avoid complicated multi-level filters we inject (piggyback) the step automation_mode into the workup.
    onWorkupChange({ name: 'automation_mode', value: processStep?.automation_mode })
    // eslint-disable-next-line
  }, [activity.activity_name, processStep?.automation_mode])

  const customActivityFormSection = {
    'ADD': AddSampleForm,
    'SAVE': SaveSampleForm,
    'TRANSFER': TransferForm,
    'EVAPORATION': EvaporationForm,
    'MERGE_SAMPLES': MergeSamplesForm,
    'MIXING': MixingForm,
    'GAS_EXCHANGE': GasExchangeForm,
    'ANALYSIS_CHROMATOGRAPHY': AnalysisChromatographyForm,
    'ANALYSIS_SPECTROSCOPY': AnalysisSpectroscopyForm,
    'ANALYSIS_ELEMENTAL': AnalysisElementalForm,
    'CHROMATOGRAPHY': ChromatographyForm,
    'CENTRIFUGATION': CentrifugationForm,
    'CRYSTALLIZATION': CrystallizationForm,
    'EXTRACTION': ExtractionForm,
    'FILTRATION': FiltrationForm,
    'DEFINE_FRACTION': DefineFractionForm,
    'WAIT': WaitForm,
    'DISCARD': DiscardForm
  }

  const renderCustomActivityForm = () => {
    let CustomActivityForm = customActivityFormSection[activity.activity_name]

    return CustomActivityForm ?
      <CustomActivityForm
        activity={activity}
        workup={workup}
        onWorkupChange={onWorkupChange}
        preconditions={preconditions}
        reactionProcessVessel={activity.reaction_process_vessel}
        onChangeVessel={onChangeVessel}
        isPersisted={!!activity.id}
      /> :
      <>Activity of type {activity.activity_name} has no Form</>
  }
  const renderDeviceOntologiesForm = () => {
    const deviceFormIncluded = ['ANALYSIS_CHROMATOGRAPHY', 'ANALYSIS_SPECTROSCOPY', 'ANALYSIS_ELEMENTAL', 'CHROMATOGRAPHY'].includes(actionTypeName)

    return deviceFormIncluded ? <></> :
      <DeviceMethodFormSet
        activity={activity}
        onWorkupChange={onWorkupChange} />
  }

  return (
    <ActivityForm
      type='action'
      activity={activity}
      onCancel={onCancel}
      onSave={onSave}
      onWorkupChange={onWorkupChange}
      onChangeDuration={onChangeDuration} >
      <FractionFormGroup fraction={activity.consumed_fraction} />
      {renderDeviceOntologiesForm()}
      {renderCustomActivityForm()}
    </ActivityForm >
  );
};


export default ActionForm;
