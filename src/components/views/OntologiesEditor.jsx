import React, { useEffect, useState } from 'react';

import { Input, Nav, NavItem, NavbarBrand, Button, Label } from "reactstrap";

import OntologyListItem from '../ontologies/OntologyListItem';
import OntologyFormModal from '../ontologies/OntologyFormModal';

import { useReactionsFetcher } from "../../fetchers/ReactionsFetcher";

import { OntologyConstants } from '../../constants/OntologyConstants';

import { SelectOptions } from '../../contexts/SelectOptions';

import Select from 'react-select';

const OntologiesEditor = () => {
  const [ontologies, setOntologies] = useState([])
  const reactionApi = useReactionsFetcher();
  const [showNewForm, setShowNewForm] = useState(false)

  const [ontologyQuery, setOntologyQuery] = useState('');
  const downcasedQuery = ontologyQuery?.toLowerCase()

  const [filter, setFilter] = useState(
    {
      "active": ["true", "false"],
      "ontology_type": OntologyConstants.ontologyTypes
    }
  )

  const ontologyMatchesQuery = (ont) =>
    ont.ontology_id?.toLowerCase().match(downcasedQuery)
    || ont.label?.toLowerCase().match(downcasedQuery)
    || ont.name?.toLowerCase().match(downcasedQuery)

  const ontologyMatchesFilter = (ontology) =>
    Object.entries(filter).every(([filterKey, requiredValues]) =>
      !OntologyConstants.ontologyTypes.includes(ontology[filterKey]) || requiredValues.includes(ontology[filterKey].toString()))

  const filteredOntologies = ontologies.filter((ont) => ontologyMatchesQuery(ont) && ontologyMatchesFilter(ont))

  const toggleFilter = (key) => (value) => () => {
    let newFilter = JSON.parse(JSON.stringify(filter))
    let index = newFilter[key].indexOf(value)

    if (index > -1) {
      newFilter[key].splice(index, 1);
    } else {
      newFilter[key].push(value)
    }
    setFilter(newFilter)
  }


  const [itemsPerPage, setItemsPerPage] = useState(100)
  const [currentPage, setCurrentPage] = useState(1)

  const perPageOptions = [{ value: 5, label: 5 }, { value: 10, label: 10 }, { value: 20, label: 20 }, { value: 50, label: 50 }, { value: 100, label: 100 }, { value: 200, label: 200 }, { value: 500, label: 500 }, { value: 10000, label: "All" }]

  const totalPages = Math.max(1, Math.ceil(filteredOntologies.length / itemsPerPage))
  const visiblePage = Math.max(1, Math.min(currentPage, totalPages))

  const firstIndex = (visiblePage - 1) * itemsPerPage
  const lastIndex = Math.min(firstIndex + itemsPerPage - 1, filteredOntologies.length)
  const paginatedOntologies = filteredOntologies.slice(firstIndex, lastIndex)



  useEffect(() => {
    if (localStorage.getItem("bearer_auth_token")) {
      fetchOntologies();
    }
    window.addEventListener("requireReload", fetchOntologies);

    return () => {
      window.removeEventListener("requireReload", fetchOntologies);
    };
    // eslint-disable-next-line
  }, [])

  const fetchOntologies = () => {
    reactionApi.getOntologies().then((data) => {
      data?.ontologies && setOntologies(data.ontologies);
    });
  };

  const initialOntology = {
    roles: {}, label: '', name: '', ontology_id: '', ontology_type: "CUSTOM_TERMINOLOGY",
    active: true, detectors: [], solvents: [], stationary_phase: []
  }

  const renderFilterCheckbox = (label, key, value) => {
    return (
      <div className="d-flex align-content-start">
        <Input
          className={"me-2"}
          type="checkbox"
          checked={filter[key]?.includes(value)}
          onChange={toggleFilter(key)(value)}
        /> {label}
      </div>
    )
  }

  return (
    <>
      <SelectOptions.Provider value={{ ontologies: ontologies }}>
        <Nav fill className="navbar fixed-bottom bg-preparation px-5">
          <NavbarBrand>
            <Button onClick={e => setShowNewForm(true)}>+ Ontology</Button>
          </NavbarBrand>
          <NavItem>
            <Input
              className="mt-2 flex-grow-1"
              placeholder={'Search Ontologies'}
              value={ontologyQuery}
              onChange={(event) => setOntologyQuery(event.target.value)}
            />
          </NavItem>
          <NavItem>
            <span >
              {'Filtered: ' + filteredOntologies.length}
              <br />
              {'Total: ' + ontologies.length}
            </span>
          </NavItem>
          <NavItem>
            {renderFilterCheckbox("Active", "active", "true")}
            {renderFilterCheckbox("Inactive", "active", "false")}
          </NavItem>
          <NavItem>
            {renderFilterCheckbox("Terminology", "ontology_type", "TERMINOLOGY")}
            {renderFilterCheckbox("Custom Terminology", "ontology_type", "CUSTOM_TERMINOLOGY")}
          </NavItem>
          <NavItem>
            {renderFilterCheckbox("Device Type", "ontology_type", "DEVICE_TYPE")}
            {renderFilterCheckbox("Device Config", "ontology_type", "DEVICE_CONFIG")}
          </NavItem>
          <NavItem>
            <button
              className="mx-2"
              onClick={() => setCurrentPage(1)}
              disabled={visiblePage === 1}
            >
              {'<<'}
            </button>
            <button
              className="mx-2"
              onClick={() => setCurrentPage(prev => Math.max(Math.min(totalPages, prev) - 1, 1))}
              disabled={visiblePage === 1}
            >
              {'<'}
            </button>
          </NavItem>
          <NavItem>
            <div>{(firstIndex + 1) + ' - ' + (lastIndex + 1)}</div>
            <div>Page {visiblePage} of {totalPages}</div>
          </NavItem>
          <NavItem>
            <button
              className="mx-2"
              onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
              disabled={visiblePage === totalPages}
            >
              {'>'}
            </button>
            <button
              className="mx-2"
              onClick={() => setCurrentPage(totalPages)}
              disabled={visiblePage === totalPages}
            >
              {'>>'}
            </button>
          </NavItem>
          <Select
            className="react-select--overwrite"
            classNamePrefix="react-select"
            value={{ value: itemsPerPage, label: itemsPerPage }}
            options={perPageOptions}
            onChange={selected => setItemsPerPage(selected.value)}
            menuPlacement={"auto"}
          />
          <Label className="p-2">Per Page</Label>
        </Nav>

        <OntologyFormModal
          key={"ontology_new"}
          ontology={initialOntology}
          isOpen={showNewForm}
          onClose={e => setShowNewForm(false)}
        />

        <table className="table table-striped w-auto">
          <tbody>
            {paginatedOntologies.map(ontology => {
              return (
                <tr key={"ontology-list-row" + ontology.ontology_id}>
                  <OntologyListItem ontology={ontology} />
                </tr>
              )
            })}
          </tbody>
        </table >
      </SelectOptions.Provider>
    </>
  )
}

export default OntologiesEditor;
