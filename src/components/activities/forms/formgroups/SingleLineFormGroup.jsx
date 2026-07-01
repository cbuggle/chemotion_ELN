import React from 'react';
import { FormGroup, Label } from "reactstrap";
import TooltipButton from "../../../utilities/TooltipButton";

const SingleLineFormGroup = (
  {
    label,
    tooltip,
    children, 
    tooltipColor
  }) => {
  return (
    <FormGroup className='row gx-2 pt-1'>
      <Label className='col-5 col-form-label d-flex'>
        {label}
        {tooltip &&
          <TooltipButton tooltip={tooltip} color={tooltipColor} />
        }
      </Label>
      <div className='col-7'>
        {children}
      </div>
    </FormGroup>
  );
};

export default SingleLineFormGroup;
