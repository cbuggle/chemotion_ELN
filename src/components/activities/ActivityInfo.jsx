import React, { useContext } from "react";

import AddInfo from "./forms/actions/info/AddInfo";

import AnalysisChromatographyInfo from "./forms/actions/info/AnalysisChromatographyInfo";
import AnalysisSpectroscopyInfo from "./forms/actions/info/AnalysisSpectroscopyInfo";

import ConditionInfo from "./forms/actions/info/ConditionInfo";
import DiscardInfo from "./forms/actions/info/DiscardInfo";
import GasExchangeInfo from "./forms/actions/info/GasExchangeInfo";
import MergeSamplesInfo from "./forms/actions/info/MergeSamplesInfo";
import PurificationInfo from "./forms/actions/info/PurificationInfo";
import RemoveInfo from "./forms/actions/info/RemoveInfo";
import SaveInfo from "./forms/actions/info/SaveInfo";
import TransferInfo from "./forms/actions/info/TransferInfo";
import WaitInfo from "./forms/actions/info/WaitInfo";

import ActivityInfoDecorator from "../../decorators/ActivityInfoDecorator";

import { SelectOptions } from "../../contexts/SelectOptions";


const ActivityInfo = (props) => {
  const selectOptions = useContext(SelectOptions);

  const activity = props.activity
  const workup = activity.workup;

  const renderActivityInfo = () => {

    let ActivityInfoComponent = {
      'ADD': AddInfo,
      'ANALYSIS_CHROMATOGRAPHY': AnalysisChromatographyInfo,
      'ANALYSIS_SPECTROSCOPY': AnalysisSpectroscopyInfo,
      'CONDITION': ConditionInfo,
      'CENTRIFUGATION': PurificationInfo,
      'CRYSTALLIZATION': PurificationInfo,
      'CHROMATOGRAPHY': PurificationInfo,
      'FILTRATION': PurificationInfo,
      'EXTRACTION': PurificationInfo,
      'EVAPORATION': RemoveInfo,
      'GAS_EXCHANGE': GasExchangeInfo,
      'MERGE_SAMPLES': MergeSamplesInfo,
      'SAVE': SaveInfo,
      'TRANSFER': TransferInfo,
      'DEFINE_FRACTION': DiscardInfo,
      'DISCARD': DiscardInfo,
      'WAIT': WaitInfo,
    }[activity.activity_name]

    if (ActivityInfoComponent) {
      return (<ActivityInfoComponent {...props} />
      )
    } else {
      return activity.activity_name || "Error in ActivityInfo. Activity has no activity_name."
    }
  };

  const renderFractionsInfo = () => {
    let fraction = activity.consumed_fraction
    let infoLine = fraction ?
      "Fraction #" + fraction.position + ': ' + (fraction.vials.length || 'No') + " Vials"
      : ''
    return (<>{infoLine}</>)
  }

  const renderEquipmentLines = () => {
    return ActivityInfoDecorator.infoLineEquipment(workup.EQUIPMENT, selectOptions.equipment)
  }

  const renderWorkupDescription = () => {
    return workup.description ?
      <p className="activity-info__description">
        {workup.description}
      </p>
      : <></>
  }

  return <>
    <div className="d-flex">
      <div className="activity-info__text-block">
        {renderFractionsInfo()}
        {renderActivityInfo()}
        {renderEquipmentLines()}
        {renderWorkupDescription()}
      </div>
    </div>
  </>
};

export default ActivityInfo;
