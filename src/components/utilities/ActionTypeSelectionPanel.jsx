import React from 'react';
import { Button, Row, Col } from "reactstrap";
import { actionTypeClusters } from "../../constants/actionTypeClusters";

const ActionTypeSelectionPanel = ({ onSelect }) => {
  const columns = actionTypeClusters

  const renderActionCluster = (cluster, cIndex) => {
    return (
      <div className="type-selection-panel__action">
        <h5>{cluster.label}</h5>
        {cluster.actions.map((action, aIndex) => (
          <Button
            key={action.id + ' ' + cIndex + ' ' + aIndex}
            onClick={onSelect(action.activity)}
            className='col-12 btn-action'
          >
            {action.createLabel}
          </Button>
        ))}
      </div>)
  }

  return (
    <Row className='type-selection-panel'>
      {columns.map((column, cIndex) => (
        <Col key={" " + column.id + cIndex} className='type-selection-panel__cluster col-6'>
          {column.map((cluster) => renderActionCluster(cluster))}
          {(cIndex > 0) &&
            <div className="type-selection-panel__action">
              <h5>{"Merge Samples"}</h5>
              < Button
                key={'merge-samples'}
                className='col-12 btn-action'
                disabled
              >
                {"Merging Samples only possible in ELN"}
              </Button>
            </div>
          }
        </Col>
      ))}
    </Row>
  );
};

export default ActionTypeSelectionPanel;
