import { api, LightningElement } from 'lwc';

export default class MapaTerapiaCetogenica extends LightningElement {

    direccion = 'Dirección: ';
    ciudad = 'Ciudad: ';
    telefono = 'Teléfono: ';
    contacto = 'Contacto: ';
    email = 'Email: ';
    listMarker = [];
    json = [
        {
         "denominacionEnPagina": "Fleni",
         "direccion": "Montañeses 2325",
         "latitude": "-34.554911441653275",
         "longitude": "-58.450734522704224",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "011 5777-3200",
         "contacto": "Dr Pablo Jorrat, Dra Cecilia Diez, Lic Diego Querze y Dra. Abril Marone",
         "emails": "teracetopedia@fleni.org.ar"
        },
        {
         "denominacionEnPagina": "Hospital Italiano de Buenos Aires - Infantil",
         "direccion": "Juan D. Perón 4190",
         "latitude": "-34.60687763872995",
         "longitude": "-58.42653217325112",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "(011) 4959-0200 int. 9624",
         "contacto": "Dra. María Vaccarezza Dra. Cecilia Diez y Dra. Lorena Santillán",
         "emails": "dieta.cetogenica.hiba@gmail.com"
        },
        {
         "denominacionEnPagina": "Hospital Italiano de Buenos Aires - Adultos",
         "direccion": "Juan D. Perón 4190",
         "latitude": "-34.60687763872995",
         "longitude": "-58.42653217325112",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "contacto": "Dra. Bárbara Rosso y Lic. Alejandra Delfante",
         "emails": "dietacetogenica.adultos@gmail.com"
        },
        {
         "denominacionEnPagina": "Hospital Posadas",
         "direccion": "Avenida Presidente Arturo U. Illia s\/n y Marconi Morón 386",
         "latitude": "-34.63004913433286",
         "longitude": "-58.575313873250536",
         "ciudad": "El Palomar",
         "provincia": "Buenos Aires",
         "contacto": "Dra. Luciana Caramuta, Dra. Patricia Sosa, Dra. Josefina Mosteirin y Lic. Samantha Becker",
         "emails": "neurologiainfantil@hospitalposadas.gov.ar"
        },
        {
         "denominacionEnPagina": "Hospital San Rafael",
         "direccion": "Comandante Torres 150",
         "latitude": "-34.619903396980924",
         "longitude": "-68.32512473092139",
         "ciudad": "San Rafael",
         "provincia": "Mendoza",
         "contacto": "Dra. Romina Fernandez, Dra. Laura Piastrelini y Lic. Florencia Salcedo"
        },
        {
         "denominacionEnPagina": "Centro CINNES",
         "direccion": "Manuel Ugarte 1665",
         "latitude": "-34.55203257996953",
         "longitude": "-58.454507459758304",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "11-2525-9187",
         "contacto": "Dr. Santiago flesler, Dra. Cecilia Araujo, Dra. Luciana Caramuta, Lic. Rocio Viollaz y Lic. Julieta Cersosimo.",
         "emails": "info@cinnes.org"
        },
        {
         "denominacionEnPagina": "Hospital Rawsan",
         "direccion": "Avenida Rawson Sur 494 Tel 0264 422-2272",
         "latitude": "-31.539236825638135",
         "longitude": "-68.51321805983847",
         "ciudad": "San Juan",
         "provincia": "San Juan",
         "telefono": "2644750256",
         "contacto": "Dra. Natacha Bazan, Dra. Ana Paula Rodriguez y Lic. Gabriela Alvarez",
         "emails": "dietacetogenica.sanjuan@gmail.com"
        },
        {
         "denominacionEnPagina": "Hospital Alemán",
         "direccion": "Av. Pueyrredón 1640",
         "latitude": "-34.5917652335998",
         "longitude": "-58.40249000208693",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "(011) 4827-7000 interno: 2617",
         "contacto": "Dra. Marisol Toma, Lic. Mariana Diz y Dra. Josefina Mosteirin.",
         "emails": "dchaleman@gmail.com"
        },
        {
         "denominacionEnPagina": "Hospital de Clínicas",
         "direccion": "Avenida Cordoba 2351",
         "latitude": "-34.59894671518727",
         "longitude": "-58.40000557325137",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "011 5950-8000",
         "contacto": "Dr. Rodolfo Benavente y Lic. Beatriz Grippo"
        },
        {
         "denominacionEnPagina": "Hospital Garrahan",
         "direccion": "Combate de los Pozos 1881",
         "latitude": "-34.6305308158162",
         "longitude": "-58.3915652020858",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "011 4308-4300 Interno 6247",
         "contacto": "Dr. Roberto Caraballo, Dra. Marisa Armeno, Dra. Gabriela Reyes, Lic. Araceli Cresta, Lic. Daniela Gargiullo y Lic. Macarena Mannarino",
         "emails": "dietacetogenicagarrahan@gmail.com"
        },
        {
         "denominacionEnPagina": "Hospital Juan A. Fernández",
         "direccion": "Av. Cerviño 3356",
         "latitude": "-34.581286170728575",
         "longitude": "-58.40711038492545",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "011 4808-2600",
         "contacto": "Dra. Marisol Toma y Lic. Mariana Diz",
         "emails": "dcfernandez@gmail.com"
        },
        {
         "denominacionEnPagina": "Centro Médico Indoor Gardens",
         "direccion": "25 de Mayo 1231",
         "latitude": "-33.30853215364622",
         "longitude": "-66.33921484445116",
         "ciudad": "San Luis",
         "provincia": "San Luis",
         "telefono": "(0266) 442 3924",
         "contacto": "Dra. Fernanda Garro, Lic. Jesica Bustos y Lic. Virginia Bessera"
        },
        {
         "denominacionEnPagina": "Hospital Humberto Notti - Neuroinfan",
         "direccion": "Av. Perú 756",
         "latitude": "-32.89251923848459",
         "longitude": "-68.84949724446226",
         "ciudad": "Mendoza",
         "provincia": "Mendoza",
         "telefono": "(0261) 429-7107 y 566-5946",
         "contacto": "Dra. María Beatriz Gamboni, Dra. Amal Hassan y Lic. Laura Pesce",
         "emails": "neuroinfan@gmail.com"
        },
        {
         "denominacionEnPagina": "Bahía Blanca",
         "direccion": "Montevideo 81",
         "latitude": "-38.728948864108844",
         "longitude": "-62.25478165963866",
         "ciudad": "Bahía Blanca",
         "provincia": "Buenos Aires",
         "telefono": "(0291) 644-7851",
         "contacto": "Dr. Pablo Matarrese, Dra. Romina Lambert y Lic. María Ana Parrota"
        },
        {
         "denominacionEnPagina": "Hospital de Niños Sor María Ludovica",
         "direccion": "Calle 14 1631",
         "latitude": "-34.93227848518866",
         "longitude": "-57.94304664440691",
         "ciudad": "La Plata",
         "provincia": "Buenos Aires",
         "telefono": "(0221) 453-5901 int. 1554",
         "contacto": "Dr. Sebastian Basanta, Dra. María Julia Alberti y Lic. Rocío Viollaz",
         "emails": "inter.consultasnutricion@gmail.com - serviciodeneurologiahsml@gmail.com"
        },
        {
         "denominacionEnPagina": "Hospital Privado de Comunidad",
         "direccion": "Córdoba 4545",
         "latitude": "-38.02217523919661",
         "longitude": "-57.5655369028045",
         "ciudad": "Mar del Plata",
         "provincia": "Buenos Aires",
         "telefono": "(0223) 499-0000",
         "contacto": "Dr. Sergio Gonorazky, Lic. María Victoria Garbarini, Lic Estefanía Echalar, Lic. María Laura Neme y Lic. Xiomara Badra"
        },
        {
         "denominacionEnPagina": "Clinica Pueyrredón de Mar del Plata - Adultos",
         "direccion": "Jujuy 2167, Piso 3",
         "latitude": "-37.998827742901845",
         "longitude": "-57.55813432897816",
         "ciudad": "Mar del Plata",
         "provincia": "Buenos Aires",
         "telefono": "(0223) 4992400",
         "contacto": "Dr. Leonel Migliachi, Dr. Leandro Gomez Ferrante y Lic. Sofia Ricchieri"
        },
        {
         "denominacionEnPagina": "IPENSA",
         "direccion": "Calle 59 Número 434",
         "latitude": "-34.916691833277426",
         "longitude": "-57.93920244440743",
         "ciudad": "La Plata",
         "provincia": "Buenos Aires",
         "telefono": "54 9 2214 27-1190",
         "contacto": "Dr. Francisco Vilavedra, Dra. Maria Julia Alberti y Lic. Rocio Viollaz"
        },
        {
         "denominacionEnPagina": "CINEA",
         "direccion": "Bernardo de Monteagudo 639",
         "latitude": "-26.823094276818388",
         "longitude": "-65.19809035392092",
         "ciudad": "San Miguel de Tucumán",
         "provincia": "Tucumán",
         "telefono": "54 9 3812466922",
         "contacto": "Dra. Constanza Pasteria, Dra. Eliana Ortiz y Lic. Belen Gordillo",
         "emails": "terapiacetogenicatucuman@gmail.com\/contipasteris@gmail.com"
        },
        {
         "denominacionEnPagina": "Consultorios Privados Dra. Marisa Armeno &amp; equipo",
         "direccion": "Las Heras 1756 PB",
         "latitude": "-34.592117634236466",
         "longitude": "-58.391607717427924",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "telefono": "(011) 4801-7750",
         "contacto": "Dra. Marisa Armeno, Dra. Antonela Verini, Lic. Eugenia Caballero y Lic. Nadia Galarza",
         "emails": "terapiascetogenicas@gmail.com"
        },
        {
         "denominacionEnPagina": "Hospital Materno Infantil de Salta",
         "direccion": "Av Sarmiento 1301",
         "latitude": "-24.771326743090622",
         "longitude": "-65.41516044465685",
         "ciudad": "Salta",
         "provincia": "Salta",
         "telefono": "0800-555-7755",
         "contacto": "Dra. Gabriela Pacheco, Dr. Ramiro Gil, Dra. Gabriela Delturco y Lic. Mariana Morales"
        },
        {
         "denominacionEnPagina": "Hospital Quintana",
         "direccion": "José Hernández 624",
         "latitude": "-24.181067921981498",
         "longitude": "-65.31512623699899",
         "ciudad": "San Salvador de Jujuy",
         "provincia": "Jujuy",
         "telefono": "0388 424-5005",
         "contacto": "Dra. Mariela De La Vega, Dra. Mara Morales, Dra. Patricia Pasayo y Lic. Marco Jerez"
        },
        {
         "denominacionEnPagina": "PRIVADO",
         "direccion": "Bolívar 2377. 3er piso. Kindy",
         "latitude": "-27.366247650367896",
         "longitude": "-55.89960206118224",
         "ciudad": "Posadas",
         "provincia": "Misiones",
         "telefono": "54 9 3764 10-8655",
         "contacto": "Dr. Lucas Beltran, Dra. Andrea Escalante y Lic. Mariela Melo",
         "emails": "aescalantemarassi@gmail.com"
        },
        {
         "denominacionEnPagina": "TeCeTuc",
         "direccion": "Marcos Paz 135",
         "latitude": "-26.822203662557026",
         "longitude": "-65.19684043244163",
         "ciudad": "San Miguel de Tucumán",
         "provincia": "Tucumán",
         "telefono": "381-4225621",
         "contacto": "Dr. Sebastián Fortini, Dra. Catalina Martorell y Lic. Paola Ramos"
        },
        {
         "denominacionEnPagina": "Clínica Reina Fabiola",
         "direccion": "Jacinto Ríos 554, 4° piso",
         "latitude": "-31.410119818917543",
         "longitude": "-64.1670464598419",
         "ciudad": "Córdoba",
         "provincia": "Córdoba",
         "telefono": "351 4142121",
         "contacto": "Dr. Ignacio Sfaello, Dra. Paula Vaudagna y Lic. Ines Bertero"
        },
        {
         "denominacionEnPagina": "Hospital de Niños de la Santísima Trinidad",
         "direccion": "Bajada Pucará 787",
         "latitude": "-31.427149457055748",
         "longitude": "-64.1696517579947",
         "ciudad": "Córdoba",
         "provincia": "Córdoba",
         "telefono": "(0351) 458-6459",
         "contacto": "Dra. Valeria Faustinelli, Dra. Nora Boiochi, Lic. Graciela Marietti"
        },
        {
         "denominacionEnPagina": "Hospital de Niños Dr. Orlando Alassia",
         "direccion": "Mendoza 4151",
         "latitude": "-31.64440860882915",
         "longitude": "-60.72734052915389",
         "ciudad": "Santa Fe",
         "provincia": "Santa Fe",
         "telefono": "342 4505931",
         "contacto": "Lic. Marisa Fernández, Lic. Cecilia Montalbetti y Dra. Viviana Ríos",
         "emails": "vivi_rios23@yahoo.com.ar"
        },
        {
         "denominacionEnPagina": "Hospital Materno Infantil San Roque",
         "direccion": "La Paz 435",
         "latitude": "-31.7299517013442",
         "longitude": "-60.52159014449275",
         "ciudad": "Paraná",
         "provincia": "Entre Ríos",
         "contacto": "Dra. Claudia Bautista, Dra. Judith Bautista y Lic. Marisa Fernandez"
        },
        {
         "denominacionEnPagina": "Hospital Elizalde",
         "direccion": "Av. Montes de Oca 40",
         "latitude": "-34.62915658573455",
         "longitude": "-58.37718631742684",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "contacto": "Dr. Adrian Binelli, Dra. Nuria Grimberg y Lic. Alejandra Franchiello"
        },
        {
         "denominacionEnPagina": "Hospital Ramon Carrillo",
         "direccion": "Francisco Pascasio Moreno 601",
         "latitude": "-41.13645691306041",
         "longitude": "-71.29947765771846",
         "ciudad": "Bariloche",
         "provincia": "Bariloche",
         "contacto": "Dra. Elisa Perez, Lic. Ana Lais, Dra. Anabel Rodriguez y Lic. Mariano Vallejo"
        },
        {
         "denominacionEnPagina": "Hospital Ramos Mejía",
         "direccion": "Gral. Urquiza 609",
         "latitude": "-34.61748715067538",
         "longitude": "-58.409594186745146",
         "ciudad": "Ciudad Autónoma de Buenos Aires",
         "provincia": "Ciudad Autónoma de Buenos Aires",
         "contacto": "Dr. Damian Consalvo, Dra. Natalia Piris, Dr. Claudio Graziadio, Lic. Maria del Mar Pasman y Lic. Gabriela Sass"
        },
        {
         "denominacionEnPagina": "HPR",
         "direccion": "20 de Febrero 598",
         "latitude": "-41.1372576344847",
         "longitude": "-71.3120267153889",
         "ciudad": "Bariloche",
         "provincia": "Bariloche",
         "contacto": "Dr. Marcelo Diblasi, Dra. Alejandra Ferrari y Lic. Graciela Boretzky"
        }
    ];
    listMarkerFiltered = [];
    error;

    connectedCallback(){
        for(let i in this.json){
            let infoDireccion = 
                '<span style="font-family: MontserratSemiBold;">'+this.direccion+'</span>'+this.json[i].direccion+'<br>'+
                '<span style="font-family: MontserratSemiBold;">'+this.ciudad+'</span>'+this.json[i].ciudad+', '+this.json[i].provincia+'<br>';
            let infoTel =
                '<span style="font-family: MontserratSemiBold;">'+this.telefono+'</span>'+this.json[i].telefono+'<br>';
            let infoContacto = 
                '<span style="font-family: MontserratSemiBold;">'+this.contacto+'</span>'+this.json[i].contacto+'<br>';
            let infoEmail =
                '<span style="font-family: MontserratSemiBold;">'+this.email+'</span>'+this.json[i].emails;

            let info = infoDireccion;
            (this.json[i].telefono) ? info += infoTel + infoContacto : info += infoContacto;
            (this.json[i].emails) ? info += infoEmail : info;

            let newObj = {
                location: {
                    Street: this.json[i].direccion,
                    Latitude: this.json[i].latitude,
                    Longitude: this.json[i].longitude,
                },
                value: 'location00'+i,
                title: this.json[i].denominacionEnPagina,
                description: info,
                icon: 'utility:checkin'
            }
            this.listMarker.push(newObj);
        }
        this.listMarkerFiltered = this.listMarker;
    }

    filter(){
        this.error = '';
        let value = this.template.querySelector('[data-id="ubicacion-input"]').value;
        var filtered = this.listMarker.filter(function(el){
            return el.title.toLowerCase().includes(value.toLowerCase()) || 
            el.location.Street.toLowerCase().includes(value.toLowerCase()) ||
            el.description.toLowerCase().includes(value.toLowerCase());
        });
        if(filtered.length > 0){
            this.listMarkerFiltered = filtered;
        }
        else{
            this.listMarkerFiltered = this.listMarker;
            this.error = 'No se encontró valor para ' + value;
        }
    }
}