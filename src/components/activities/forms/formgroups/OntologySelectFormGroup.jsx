import React, { useContext } from 'react';
import Select from 'react-select'

import SingleLineFormGroup from './SingleLineFormGroup';

import OntologiesOptionsDecorator from '../../../../decorators/OntologiesOptionsDecorator';
import StringDecorator from '../../../../decorators/StringDecorator';

import { tooltips } from '../../../../constants/translations';
import { SelectOptions } from '../../../../contexts/SelectOptions';

const OntologySelectFormGroup = (
  {
    roleName,
    workup,
    onChange,
    label,
    disabled,
    placeholder,
    tooltip,
    options
  }) => {

  let ontologies = useContext(SelectOptions).ontologies

  options ||= ontologies

  let value = workup?.[roleName]

  let selectableOptionsMatchingWorkupDependencies =
    OntologiesOptionsDecorator.selectableOptionsMatchingWorkupDependencies(
      { options: options, ontologies: ontologies, roleName: roleName, workup: workup, key: Math.random(10000) }
    )

  let selectedOption = OntologiesOptionsDecorator.findByOntologyId({ ontologyId: value, ontologies: selectableOptionsMatchingWorkupDependencies })

  tooltip ||= selectedOption?.unavailable && tooltips['selection_unavailable']
  tooltip ||= selectedOption && !selectedOption.active && tooltips['selection_inactive']
  tooltip ||= selectedOption?.unmetDependency && tooltips['selection_unmet_dependency']

  label ||= StringDecorator.toLabelSpelling(roleName)

  return (<>
    <SingleLineFormGroup
      key={"form-group-" + roleName + "-" + value + Math.random(10000)}
      label={label}
      tooltip={tooltip}
      tooltipColor={"danger"}
    >

      <Select
        className="react-select--overwrite"
        classNamePrefix="react-select"
        name={roleName}
        options={selectableOptionsMatchingWorkupDependencies}
        value={selectedOption}
        onChange={onChange}
        isClearable={true}
        placeholder={placeholder}
        isDisabled={disabled || selectableOptionsMatchingWorkupDependencies.length === 0}
      />
    </SingleLineFormGroup>
  </>
  );
};

export default OntologySelectFormGroup;

