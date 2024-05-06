import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const showToast = (
	variant = 'info',
	mode = 'dismissable',
	title,
	message
) => {
	const event = new ShowToastEvent({
		title: title,
		message: message,
		mode: mode,
		variant: variant
	});

	return event;
}

const formatDateddMMShortyyyy = (stringDate = new Date().toDateString()) => {
	if (stringDate == undefined || stringDate == '' || stringDate == null) {
		return;
	}

	// let date = new Date(stringDate.split('T')[0]).getTime();
	let d = new Date(stringDate.replace('-', '/'));

	let ye = new Intl.DateTimeFormat('en', {year: 'numeric'}).format(d);
	let mo = new Intl.DateTimeFormat('en', {month: 'short'}).format(d);
	let da = new Intl.DateTimeFormat('en', {day: '2-digit'}).format(d);

	return `${da} ${mo} ${ye}`;
}

const formatDate = (date = new Date().toDateString(), stringFormat, separator, options) => {
	if (date == undefined || date == '' || date == null) {
		return;
	}

	let d = new Date(date.replace('-', '/'));

	// options example
	// year: 'numeric'
	// month: 'short'
	// day: '2-digit'

	let ye = new Intl.DateTimeFormat('en', {year: options.year}).format(d);
	let mo = new Intl.DateTimeFormat('en', {month: options.month}).format(d);
	let da = new Intl.DateTimeFormat('en', {day: options.day}).format(d);

	if (stringFormat === 'ddMMyyyy') {
		return `${da}${separator}${mo}${separator}${ye}`;
	} else if (stringFormat === 'yyyyMMdd') {
		return `${ye}${separator}${mo}${separator}${da}`;
	} else if (stringFormat === 'MMddyyyy') {
		return `${mo}${separator}${da}${separator}${ye}`;
	}
}

const isValidDate = (value) => {
	return (new Date(value) !== 'Invalid Date') &&
		!isNaN(new Date(value));
}

const dateRangeValidationResponse = (isValid) => {
	let response;

	return {
		setValidationResult: function (valid) {
			isValid = valid;
		},
		getValidationResult: function () {
			return isValid;
		},
		setResponse: function (oResponse) {
			response = oResponse;
		},
		getResponse: function () {
			return response;
		}
	}
}

const isValidDateRange = (startDate, endDate) => {
	let sdate = new Date(startDate).getTime();
	let edate = new Date(endDate).getTime();
	let response = dateRangeValidationResponse(true);

	if (sdate > edate) {
		response.setValidationResult(false);
		response.setResponse({
			variant: 'error',
			mode: 'pester',
			title: 'ERROR',
			message: 'Fecha inicial no puede ser mayor a la final.'
		});
	}

	return response;
}

const fillDataTable = (response, hasMoreThanOneHyperlink) => {
	let processed = {
		columns: [],
		data: []
	};

	processed.columns = response.GridColumns;
	Object.keys(response.GridData).forEach(id => {
		let record = response.GridData[id];

		response.GridColumns.forEach(column => {
			let key = column.fieldName;

			if (key != undefined || key != 'PDFFileLink') {
				let value = record[key];

				if (value && column.type == 'DATE') {
					if (isValidDate(value)) {
						record[key] = formatDateddMMShortyyyy(value);
					}
				} else if (value && column.fieldName.indexOf('Link') > -1) {
					if (hasMoreThanOneHyperlink) {
						record[key] = '/' + record[key];
					} else {
						record[key] = '/' + id;
					}
				} else if (!value) {
					record[key] = '';
				}
			}
		});

		processed.data.push(record);
	});

	return processed;
}

const cloneInputs = (inputs) => {
	let inputsToClone = inputs.filter(input => input.toClone);

	inputsToClone.forEach(input => {
		let index = inputs.indexOf(input, 0);

		if (index > -1) {
			if (input.type == 'date') {
				if (input.fieldPath == 'startDate') {
					let date = new Date();
					let inputToClone = Object.assign({}, input);
					inputToClone.label = 'Fecha final';
					inputToClone.fieldPath = 'endDate';
					inputToClone.messageWhenValueMissing = 'Favor de seleccionar fecha'
					inputToClone.messageWhenRangeOverflow = 'La fecha final no puede ser mayor a la actual';
					inputToClone.toClone = false;
					inputToClone.max = new Date(date.getFullYear(), date.getMonth(), date.getDate()).toISOString();

					inputs.splice(index + 1, 0, inputToClone);
				}
			}
		}
	});
}

const exportToCSVFile = (headers, data, fileName) => {

	if (!data || !data.length) return null;

	const jsonObject = JSON.stringify(data);
	const result = convertToCSV(jsonObject, headers);

	if (result === null) return;
	const blob = new Blob([result]);
	const exportedFilename = fileName ? fileName + '.csv' : 'export.csv';

	if (navigator.msSaveBlob) {
		navigator.msSaveBlob(blob, exportedFilename);
	} else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
		const link = window.document.createElement('a');
		link.href = 'data:text/csv;charset=utf-8' + encodeURI(result);
		link.target = '_blank';
		link.download = exportedFilename;
		document.body.appendChild(link);
		link.click();
	} else {
		let link = document.createElement('a');

		if (link.download !== undefined) {
			const url = URL.createObjectURL(blob);
			link.setAttribute('href', url);
			link.setAttribute('download', exportedFilename);
			link.style.visibility = 'hidden';
			document.body.appendChild(link);
			link.click();
			document.body.removeChild(link);
		}
	}
}

function convertToCSV (objArray, headers, rowKey) {
	//const columnDelimiter = ',';
	const columnDelimiter = '|';
	const lineDelimiter = '\r\n';
	const actualHeaderKey = headers;
	const headerToShow = headers.map(header => header.label);
	let str = '';

	str += headerToShow.join(columnDelimiter);
	str += lineDelimiter;

	const data = typeof objArray !== 'object' ? JSON.parse(objArray) : objArray;
	console.log('data');
	console.log(data);
	console.log('actualHeaderKey');
	console.log(actualHeaderKey);
	data.forEach(obj => {
		let line = '';

		actualHeaderKey.forEach(key => {
			if (key.fieldName == 'PDFFileLink') {
				return;
			}
			if (line != '') {
				line += columnDelimiter;
			}

			let rowKey = key.fieldName.indexOf('Link') > -1 ? key.fieldName.replace('Link', '') : key.fieldName;
			if(rowKey == 'Dan360_ImporteDocumento__c' || rowKey == 'Dan360_Saldo__c' || rowKey == 'Dan360_Acumulado__c'){
				const srtsplit = String(obj[rowKey]).split('.');
				let strAdd = [];
				let numero = 0;
				console.log(srtsplit[0]);
				for (var i = srtsplit[0].length; i > -3; i -= 3) {
					if(i != srtsplit[0].length){
						strAdd.push(srtsplit[0].substring(i, numero));
					}
					numero = i;	
				}
				let strAddToAdd = [];
				for(i=strAdd.length-1;i>=0;i--){
					strAddToAdd.push(strAdd[i]);
				}
				console.log(strAddToAdd);
				let lineToAdd = '';
				if(strAddToAdd[0] == '-'){
					const firstElement = strAddToAdd.shift();
					lineToAdd = firstElement+'$ '+strAddToAdd.join('.');
				}else{
					if(strAddToAdd[0].startsWith('-')){
						let firstElementRemove = strAddToAdd.shift();
						let linemodify = firstElementRemove.replace('-', '-$ ');
						console.log('linemodify');
						console.log(linemodify);
						console.log(linemodify+strAddToAdd.join('.'));
						lineToAdd = linemodify+'.'+strAddToAdd.join('.');
					}else {
						lineToAdd = '$ '+strAddToAdd.join('.');
					}
					
				}
				//let lineToAdd = strAddToAdd.join('.');
				if(srtsplit[1] == undefined){
					srtsplit[1] = '00';
				}
				console.log(lineToAdd+','+srtsplit[1]);
				line += lineToAdd+','+srtsplit[1];
			} else {
				line += !obj[rowKey] ? ' ' : obj[rowKey] + '';
			}
			//line += !obj[rowKey] ? ' ' : obj[rowKey] + '';
	
		});

		str += line + lineDelimiter;
		console.log('str');
		console.log(str);
	});

	return str;
}

function formatBytes (bytes, decimals = 2) {
	if (bytes === 0) return '0 Bytes';

	const k = 1024;
	const dm = decimals < 0 ? 0 : decimals;
	// const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
	const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

	const i = Math.floor(Math.log(bytes) / Math.log(k));

	return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

const loadDataTableStyleWrapper = (dataTable, columnMinWidthSet, callback) => {
	if (dataTable) {
		dataTable.minColumnWidth = dataTable.minColumnWidth <= 50 ? 100 : dataTable.minColumnWidth;
		columnMinWidthSet = true;
	}

	if (!this.stylesLoaded) {
		Promise.all([loadStyle(this, WrappedHeaderTable)])
			.then(data => callback(data))
			.catch((error) => {
				console.error(`Error loading custom styles ${JSON.stringify(error)}`);
			});
	}
}

const processFieldSetFields = (response) => {
	let fields = JSON.parse(response);

	fields.forEach(element => {
		element.isReference = (element.type == 'reference');
		element.isPicklist = (element.type == 'picklist');
		element.isTextOrDate = (element.type == 'string' || element.type == 'date');
	});

	return fields;
}

const removeEmptyProperties = (object, element) => {
	let o = object;

	if (element) {
		delete o[element];
	} else {
		Object.keys(o)
			.forEach(key => {
				if (o[key] == '' ||
					o[key] == null ||
					o[key] == undefined
				) {
					delete o[key];
				}
			});
	}

	return o;
}

export {
	showToast,
	formatDateddMMShortyyyy,
	formatDate,
	cloneInputs,
	exportToCSVFile,
	fillDataTable,
	isValidDate,
	formatBytes,
	loadDataTableStyleWrapper,
	processFieldSetFields,
	isValidDateRange,
	removeEmptyProperties
};