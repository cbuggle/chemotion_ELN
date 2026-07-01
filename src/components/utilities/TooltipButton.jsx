import React from 'react';

import { UncontrolledTooltip } from "reactstrap";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faInfoCircle } from "@fortawesome/free-solid-svg-icons";
import { uniqueId } from 'react-bootstrap-typeahead/types/utils';

const TooltipButton = ({ tooltip, color, size }) => {
  let tooltipId = uniqueId('tooltip-')

  return (
    <>
      <FontAwesomeIcon
        id={tooltipId}
        icon={faInfoCircle}
        size={size || "sm"}
        className='ms-2 mt-1 text-danger'
        href="#"
      />
      <UncontrolledTooltip
        target={tooltipId}>
        {tooltip}
      </UncontrolledTooltip >
    </>
  );
};

export default TooltipButton;
