--
-- PostgreSQL database dump
--

\restrict CSL0PQBXftMo6fEdjVTayP4GcWzjaHulC3fJhRAJcV5XZkvgtFe13N3F1QMnGXG

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-06 18:07:23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 875 (class 1247 OID 22740)
-- Name: tipo_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipo_enum AS ENUM (
    'B',
    'A',
    'C',
    'D',
    'E',
    'T'
);


ALTER TYPE public.tipo_enum OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 23004)
-- Name: fn_log_practicas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_log_practicas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_practicas (idestudiante, tipo_operacion, duracion_anterior, duracion_nueva, descripcion)
        VALUES (
            NEW.idestudiante,
            'INSERT',
            NULL,
            NEW.duracion_minutos,
            'Nueva práctica añadida. Fecha: ' || NEW.fecha
        );

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.duracion_minutos <> NEW.duracion_minutos THEN
            INSERT INTO log_practicas (idestudiante, tipo_operacion, duracion_anterior, duracion_nueva, descripcion)
            VALUES (
                NEW.idestudiante,
                'UPDATE',
                OLD.duracion_minutos,
                NEW.duracion_minutos,
                'Duración cambiada de ' || OLD.duracion_minutos || ' a ' || NEW.duracion_minutos || ' min'
            );
        END IF;
    END IF;

    RETURN NULL; 
END;
$$;


ALTER FUNCTION public.fn_log_practicas() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 22990)
-- Name: fn_validar_instructor(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_validar_instructor() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_es_empleado INT;
BEGIN
   
    IF NEW.idempleado_instructor IS NULL THEN
        RETURN NEW; 
    END IF;

 
    SELECT COUNT(*) INTO v_es_empleado
    FROM empleados
    WHERE idpersona = NEW.idempleado_instructor;


    IF v_es_empleado = 0 THEN
        RAISE EXCEPTION
            'La persona con ID % no es un empleado de la autoescuela.',
            NEW.idempleado_instructor;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_validar_instructor() OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 22988)
-- Name: practicas_del_instructor(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.practicas_del_instructor(p_idinstructor integer) RETURNS TABLE(estudiante text, fecha date, duracion_min integer, matricula character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    cur_practicas CURSOR FOR
        SELECT
            (per.nombre || ' ' || per.apellido1)  AS nombre_est,
            prac.fecha,
            prac.duracion_minutos,
            veh.matricula
        FROM practicas prac
        JOIN ONLY personas per  ON per.idpersona  = prac.idestudiante
        LEFT JOIN vehiculos veh ON veh.idvehiculo = prac.idvehiculo
        WHERE prac.idempleado_instructor = p_idinstructor
        ORDER BY prac.fecha;

    v_fila        RECORD;       
    v_nombre_inst VARCHAR(60);  
    v_contador    INT := 0;     
BEGIN
    SELECT nombre INTO STRICT v_nombre_inst
    FROM ONLY personas
    WHERE idpersona = p_idinstructor;

    RAISE NOTICE 'Buscando prácticas de: %', v_nombre_inst;

    OPEN cur_practicas;
    LOOP
        FETCH cur_practicas INTO v_fila;
        EXIT WHEN NOT FOUND; 

        v_contador := v_contador + 1;

        estudiante   := v_fila.nombre_est;
        fecha        := v_fila.fecha;
        duracion_min := v_fila.duracion_minutos;
        matricula    := v_fila.matricula;

        RETURN NEXT;
    END LOOP;
    CLOSE cur_practicas;

    IF v_contador = 0 THEN
        RAISE NOTICE '% aún no tiene prácticas registradas.', v_nombre_inst;
    ELSE
        RAISE NOTICE 'Total de prácticas encontradas: %', v_contador;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'No existe ningún instructor con ID %.', p_idinstructor;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inesperado: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.practicas_del_instructor(p_idinstructor integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 22989)
-- Name: registrar_practica(character varying, character varying, date, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.registrar_practica(IN p_dni character varying, IN p_matricula character varying, IN p_fecha date, IN p_duracion integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_idestudiante INT;       
    v_idvehiculo   INT;         
    v_nombre       VARCHAR(60);  
BEGIN
    SELECT idpersona, nombre INTO STRICT v_idestudiante, v_nombre
    FROM ONLY personas
    WHERE dni = p_dni;

    SELECT idvehiculo INTO STRICT v_idvehiculo
    FROM vehiculos
    WHERE matricula = p_matricula;

    IF p_duracion <= 0 THEN
        RAISE EXCEPTION 'La duración debe ser mayor que 0 minutos.';
    END IF;

    INSERT INTO practicas (idestudiante, idvehiculo, fecha, duracion_minutos)
    VALUES (v_idestudiante, v_idvehiculo, p_fecha, p_duracion);

    RAISE NOTICE 'Práctica de % min registrada para % el %.', p_duracion, v_nombre, p_fecha;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION
            'No se encontró al estudiante con DNI "%" o al vehículo con matrícula "%".',
            p_dni, p_matricula;
    WHEN TOO_MANY_ROWS THEN
        RAISE EXCEPTION
            'El DNI "%" aparece duplicado en la base de datos. Contacta con el administrador.',
            p_dni;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al registrar la práctica: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.registrar_practica(IN p_dni character varying, IN p_matricula character varying, IN p_fecha date, IN p_duracion integer) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 22987)
-- Name: total_minutos_estudiante(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.total_minutos_estudiante(p_idestudiante integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_nombre VARCHAR(60);
    v_total  INT := 0;     
BEGIN
    SELECT nombre INTO STRICT v_nombre
    FROM ONLY personas
    WHERE idpersona = p_idestudiante;

    SELECT COALESCE(SUM(duracion_minutos), 0) INTO v_total
    FROM practicas
    WHERE idestudiante = p_idestudiante;

    IF v_total = 0 THEN
        RAISE NOTICE '% no tiene prácticas registradas todavía.', v_nombre;
    ELSIF v_total < 200 THEN
        RAISE NOTICE '% lleva % min. Todavía necesita más prácticas.', v_nombre, v_total;
    ELSE
        RAISE NOTICE '% lleva % min. ¡Puede presentarse al examen práctico!', v_nombre, v_total;
    END IF;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'No existe ningún estudiante con ID %.', p_idestudiante;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inesperado: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.total_minutos_estudiante(p_idestudiante integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 22754)
-- Name: personas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personas (
    idpersona integer NOT NULL,
    nombre character varying(50) NOT NULL,
    apellido1 character varying(60) NOT NULL,
    apellido2 character varying(60),
    dni character varying(9) NOT NULL,
    fecha_nac date NOT NULL,
    direccion text,
    telefono text NOT NULL
);


ALTER TABLE public.personas OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 22770)
-- Name: empleados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empleados (
    telefonos_empresa text[] DEFAULT ARRAY[]::text[],
    idjefe integer
)
INHERITS (public.personas);


ALTER TABLE public.empleados OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 22794)
-- Name: estudiantes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estudiantes (
    idvehiculo integer NOT NULL
)
INHERITS (public.personas);


ALTER TABLE public.estudiantes OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 22828)
-- Name: examenesp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.examenesp (
    idexamenp integer NOT NULL,
    direccion text NOT NULL,
    duracion_aprox_minutos integer NOT NULL,
    tipo public.tipo_enum NOT NULL,
    CONSTRAINT examenesp_duracion_aprox_minutos_check CHECK ((duracion_aprox_minutos > 0))
);


ALTER TABLE public.examenesp OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 22827)
-- Name: examenesp_idexamenp_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.examenesp_idexamenp_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.examenesp_idexamenp_seq OWNER TO postgres;

--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 227
-- Name: examenesp_idexamenp_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.examenesp_idexamenp_seq OWNED BY public.examenesp.idexamenp;


--
-- TOC entry 230 (class 1259 OID 22842)
-- Name: examenest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.examenest (
    idexament integer NOT NULL,
    direccion text NOT NULL,
    cantidad_preguntas integer NOT NULL,
    duracion_max_minutos integer NOT NULL,
    tipo public.tipo_enum NOT NULL,
    CONSTRAINT examenest_cantidad_preguntas_check CHECK ((cantidad_preguntas > 0)),
    CONSTRAINT examenest_duracion_max_minutos_check CHECK ((duracion_max_minutos > 0))
);


ALTER TABLE public.examenest OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 22841)
-- Name: examenest_idexament_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.examenest_idexament_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.examenest_idexament_seq OWNER TO postgres;

--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 229
-- Name: examenest_idexament_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.examenest_idexament_seq OWNED BY public.examenest.idexament;


--
-- TOC entry 237 (class 1259 OID 22993)
-- Name: log_practicas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_practicas (
    idlog integer NOT NULL,
    idestudiante integer,
    fecha_cambio timestamp without time zone DEFAULT now(),
    tipo_operacion character varying(10),
    duracion_anterior integer,
    duracion_nueva integer,
    descripcion text
);


ALTER TABLE public.log_practicas OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 22992)
-- Name: log_practicas_idlog_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_practicas_idlog_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_practicas_idlog_seq OWNER TO postgres;

--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 236
-- Name: log_practicas_idlog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_practicas_idlog_seq OWNED BY public.log_practicas.idlog;


--
-- TOC entry 234 (class 1259 OID 22908)
-- Name: notas_examenp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notas_examenp (
    idexamenp integer NOT NULL,
    idestudiante integer NOT NULL,
    idexaminador integer NOT NULL,
    idprofesor integer NOT NULL,
    duracion_minutos integer NOT NULL,
    aprobado boolean NOT NULL,
    fecha date NOT NULL,
    num_faltas integer NOT NULL,
    CONSTRAINT chk_examinador_profesor_distintos CHECK ((idexaminador <> idprofesor)),
    CONSTRAINT notas_examenp_duracion_minutos_check CHECK ((duracion_minutos > 0)),
    CONSTRAINT notas_examenp_num_faltas_check CHECK ((num_faltas >= 0))
);


ALTER TABLE public.notas_examenp OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 22943)
-- Name: notas_exament; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notas_exament (
    idexament integer NOT NULL,
    idestudiante integer NOT NULL,
    fecha date NOT NULL,
    duracion_minutos integer NOT NULL,
    num_aciertos integer NOT NULL,
    CONSTRAINT notas_exament_duracion_minutos_check CHECK ((duracion_minutos > 0)),
    CONSTRAINT notas_exament_num_aciertos_check CHECK ((num_aciertos >= 0))
);


ALTER TABLE public.notas_exament OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 22885)
-- Name: notas_tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notas_tests (
    idtest integer NOT NULL,
    idestudiante integer NOT NULL,
    aprobado boolean NOT NULL,
    fecha date NOT NULL,
    duracion_minutos integer NOT NULL,
    num_fallos integer NOT NULL,
    CONSTRAINT notas_tests_duracion_minutos_check CHECK ((duracion_minutos > 0)),
    CONSTRAINT notas_tests_num_fallos_check CHECK ((num_fallos >= 0))
);


ALTER TABLE public.notas_tests OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 22753)
-- Name: personas_idpersona_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personas_idpersona_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personas_idpersona_seq OWNER TO postgres;

--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 219
-- Name: personas_idpersona_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personas_idpersona_seq OWNED BY public.personas.idpersona;


--
-- TOC entry 232 (class 1259 OID 22858)
-- Name: practicas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.practicas (
    idpractica integer NOT NULL,
    idestudiante integer,
    idempleado_instructor integer,
    idvehiculo integer,
    fecha date NOT NULL,
    duracion_minutos integer NOT NULL,
    observaciones text,
    CONSTRAINT practicas_duracion_minutos_check CHECK ((duracion_minutos > 0))
);


ALTER TABLE public.practicas OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 22857)
-- Name: practicas_idpractica_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.practicas_idpractica_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.practicas_idpractica_seq OWNER TO postgres;

--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 231
-- Name: practicas_idpractica_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.practicas_idpractica_seq OWNED BY public.practicas.idpractica;


--
-- TOC entry 226 (class 1259 OID 22813)
-- Name: tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tests (
    idtest integer NOT NULL,
    cantidad_preguntas integer NOT NULL,
    duracion_max_minutos integer NOT NULL,
    tema text NOT NULL,
    dispositivo character varying(50),
    CONSTRAINT tests_cantidad_preguntas_check CHECK ((cantidad_preguntas > 0)),
    CONSTRAINT tests_duracion_max_minutos_check CHECK ((duracion_max_minutos > 0))
);


ALTER TABLE public.tests OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 22812)
-- Name: tests_idtest_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tests_idtest_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tests_idtest_seq OWNER TO postgres;

--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 225
-- Name: tests_idtest_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tests_idtest_seq OWNED BY public.tests.idtest;


--
-- TOC entry 223 (class 1259 OID 22784)
-- Name: vehiculos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehiculos (
    idvehiculo integer NOT NULL,
    matricula character varying(7) NOT NULL,
    modelo character varying(30),
    marca character varying(30),
    color character varying(30)
);


ALTER TABLE public.vehiculos OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 22783)
-- Name: vehiculos_idvehiculo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehiculos_idvehiculo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehiculos_idvehiculo_seq OWNER TO postgres;

--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 222
-- Name: vehiculos_idvehiculo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehiculos_idvehiculo_seq OWNED BY public.vehiculos.idvehiculo;


--
-- TOC entry 4915 (class 2604 OID 22773)
-- Name: empleados idpersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados ALTER COLUMN idpersona SET DEFAULT nextval('public.personas_idpersona_seq'::regclass);


--
-- TOC entry 4918 (class 2604 OID 22797)
-- Name: estudiantes idpersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiantes ALTER COLUMN idpersona SET DEFAULT nextval('public.personas_idpersona_seq'::regclass);


--
-- TOC entry 4920 (class 2604 OID 22831)
-- Name: examenesp idexamenp; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examenesp ALTER COLUMN idexamenp SET DEFAULT nextval('public.examenesp_idexamenp_seq'::regclass);


--
-- TOC entry 4921 (class 2604 OID 22845)
-- Name: examenest idexament; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examenest ALTER COLUMN idexament SET DEFAULT nextval('public.examenest_idexament_seq'::regclass);


--
-- TOC entry 4923 (class 2604 OID 22996)
-- Name: log_practicas idlog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_practicas ALTER COLUMN idlog SET DEFAULT nextval('public.log_practicas_idlog_seq'::regclass);


--
-- TOC entry 4914 (class 2604 OID 22757)
-- Name: personas idpersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas ALTER COLUMN idpersona SET DEFAULT nextval('public.personas_idpersona_seq'::regclass);


--
-- TOC entry 4922 (class 2604 OID 22861)
-- Name: practicas idpractica; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practicas ALTER COLUMN idpractica SET DEFAULT nextval('public.practicas_idpractica_seq'::regclass);


--
-- TOC entry 4919 (class 2604 OID 22816)
-- Name: tests idtest; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests ALTER COLUMN idtest SET DEFAULT nextval('public.tests_idtest_seq'::regclass);


--
-- TOC entry 4917 (class 2604 OID 22787)
-- Name: vehiculos idvehiculo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculos ALTER COLUMN idvehiculo SET DEFAULT nextval('public.vehiculos_idvehiculo_seq'::regclass);


--
-- TOC entry 5136 (class 0 OID 22770)
-- Dependencies: 221
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empleados (idpersona, nombre, apellido1, apellido2, dni, fecha_nac, direccion, telefono, telefonos_empresa, idjefe) FROM stdin;
1	Anxo	Curras	\N	12345678X	2000-11-10	Calle Calvar 99	123 456 789	{"981 111 111"}	\N
2	Angel	Mendez	\N	87654321Z	1999-07-11	Calle Pilar 87	222 222 222	{"981 111 112","981 111 212"}	\N
3	Xurxo	Fisterra	Sotelo	24681357R	1998-02-12	Calle Santarosa 14	333 333 333	{"981 111 113"}	\N
4	Jorge	Lago	Cordeiro	78945612T	1996-04-13	Calle Eduardo Chaves 69	444 444 444	{"981 111 114"}	\N
5	Miguel	Chaves	Gonzales	32165498Y	1997-09-14	Calle Piñeiro 3	555 555 555	{"981 111 115"}	\N
6	Pepe	Del Rio	\N	15975346H	1988-01-15	Calle Calvar 1	666 666 666	{"981 111 116"}	\N
7	Manuel	Magallanes	\N	46829715L	1985-03-16	Calle Piñeiro 33	777 777 777	{"981 111 117"}	\N
8	Xian	Pazo	Quente	90753124M	1990-05-17	Calle Santarosa 66	888 888 888	{"981 111 118"}	\N
9	Juan	Soto	Silva	58241976K	1989-06-18	Calle Eduardo Chaves 9	999 999 999	{"981 111 119"}	\N
10	Marta	Reina	\N	73486219P	1991-08-19	Calle Pilar 87	111 111 111	{"981 111 120"}	\N
11	Noa	Varela	\N	11223344A	1993-10-20	Rua do Sol 7	111 222 333	{"981 111 121"}	\N
12	Iria	Dominguez	Lopez	22334455B	1992-12-21	Avd Galicia 12	222 333 444	{"981 111 122"}	\N
13	Hugo	Pereira	\N	33445566C	1987-11-22	Rua Nova 5	333 444 555	{"981 111 123"}	\N
14	Lara	Suarez	Mato	44556677D	1994-02-23	Calle Palmas 3	444 555 666	{"981 111 124"}	\N
15	Brais	Molina	\N	55667788E	1986-07-24	Rua San Xoan 10	555 666 777	{"981 111 125"}	\N
\.


--
-- TOC entry 5139 (class 0 OID 22794)
-- Dependencies: 224
-- Data for Name: estudiantes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estudiantes (idpersona, nombre, apellido1, apellido2, dni, fecha_nac, direccion, telefono, idvehiculo) FROM stdin;
16	Sebas	Vazques	Rios	11112222T	2008-11-15	Calle Calvar 1	666 666 666	1
17	Aron	Martinez	\N	33334444R	2008-11-16	Calle Pilar 8771	777 777 777	2
18	Marcos	Antepazo	Ferradas	55556666Y	2008-11-17	Calle Santarosa 87	888 888 888	3
19	Alejandro	Perez	\N	77778888Q	2008-11-18	Calle Eduardo Chaves 13	999 999 999	4
20	Javi	Pucelas	Pereira	99998765S	2008-11-19	Calle Piñeiro 45	111 999 555	5
21	Nerea	Santos	\N	66778899F	2007-01-05	Rua do Regueiro 15	600 000 001	6
22	Adrian	Gomez	Paz	77889900G	2007-02-06	Rua do Regueiro 15	600 000 002	7
23	Lucia	Rodriguez	\N	88990011I	2007-03-07	Rua do Regueiro 15	600 000 003	8
24	Pablo	Alvarez	Seoane	99001122J	2007-04-08	Rua do Regueiro 15	600 000 004	9
25	Sara	Prieto	\N	10101010K	2007-05-09	Rua do Regueiro 15	600 000 005	10
26	Diego	Vazquez	\N	20202020L	2007-06-10	Calle Calvar 22	600 000 006	11
27	Ainhoa	Crespo	Lage	30303030M	2007-07-11	Calle Calvar 23	600 000 007	12
28	Izan	Nogueira	\N	40404040N	2007-08-12	Calle Calvar 24	600 000 008	13
29	Carla	Souto	Pita	50505050O	2007-09-13	Calle Calvar 25	600 000 009	14
30	Eric	Vidal	\N	60606060R	2007-10-14	Calle Calvar 26	600 000 010	15
\.


--
-- TOC entry 5143 (class 0 OID 22828)
-- Dependencies: 228
-- Data for Name: examenesp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.examenesp (idexamenp, direccion, duracion_aprox_minutos, tipo) FROM stdin;
1	Garcia Barbon	30	B
2	Sanjurjo Badia	26	D
3	Avd de Galicia	27	A
4	Calle Palmas	35	T
5	Rua San Xoan	31	C
6	Rua Venezuela	28	B
7	Gran Via	32	B
8	Rua Urzaiz	29	A
9	Plaza España	34	C
10	Travesia de Vigo	30	D
11	Rua Aragon	27	E
12	Rua Barcelona	33	B
13	Rua Zamora	25	A
14	Rua Bolivia	36	T
15	Rua Coruña	28	C
\.


--
-- TOC entry 5145 (class 0 OID 22842)
-- Dependencies: 230
-- Data for Name: examenest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.examenest (idexament, direccion, cantidad_preguntas, duracion_max_minutos, tipo) FROM stdin;
1	Rua do Regueiro 15	30	30	A
2	Rua do Regueiro 15	30	40	B
3	Rua do Regueiro 15	30	25	T
4	Rua do Regueiro 15	30	21	C
5	Rua do Regueiro 15	30	17	D
6	Rua do Regueiro 15	25	25	B
7	Rua do Regueiro 15	20	20	A
8	Rua do Regueiro 15	35	35	C
9	Rua do Regueiro 15	40	45	D
10	Rua do Regueiro 15	15	15	E
11	Rua do Regueiro 15	10	12	T
12	Rua do Regueiro 15	28	30	B
13	Rua do Regueiro 15	26	28	A
14	Rua do Regueiro 15	32	35	C
15	Rua do Regueiro 15	22	25	D
\.


--
-- TOC entry 5152 (class 0 OID 22993)
-- Dependencies: 237
-- Data for Name: log_practicas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_practicas (idlog, idestudiante, fecha_cambio, tipo_operacion, duracion_anterior, duracion_nueva, descripcion) FROM stdin;
1	26	2026-06-06 17:57:37.750249	INSERT	\N	70	Nueva práctica añadida. Fecha: 2026-02-01
2	26	2026-06-06 17:58:55.668525	UPDATE	70	90	Duración cambiada de 70 a 90 min
\.


--
-- TOC entry 5149 (class 0 OID 22908)
-- Dependencies: 234
-- Data for Name: notas_examenp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notas_examenp (idexamenp, idestudiante, idexaminador, idprofesor, duracion_minutos, aprobado, fecha, num_faltas) FROM stdin;
1	16	11	1	26	t	2025-12-10	1
2	17	12	2	28	t	2025-12-11	0
3	18	13	3	37	f	2025-12-12	7
4	19	14	4	35	f	2025-12-13	8
5	20	15	5	27	t	2025-12-14	2
6	21	11	6	30	t	2025-12-15	1
7	22	12	7	32	f	2025-12-16	4
8	23	13	8	29	t	2025-12-17	2
9	24	14	9	34	t	2025-12-18	1
10	25	15	10	30	f	2025-12-19	5
11	26	11	1	27	t	2025-12-20	2
12	27	12	2	33	t	2025-12-21	1
13	28	13	3	25	f	2025-12-22	6
14	29	14	4	36	t	2025-12-23	2
15	30	15	5	28	t	2025-12-24	1
\.


--
-- TOC entry 5150 (class 0 OID 22943)
-- Dependencies: 235
-- Data for Name: notas_exament; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notas_exament (idexament, idestudiante, fecha, duracion_minutos, num_aciertos) FROM stdin;
1	16	2025-12-10	26	28
2	17	2025-12-11	28	30
3	18	2025-12-12	25	18
4	19	2025-12-13	21	16
5	20	2025-12-14	17	27
6	21	2025-12-15	20	22
7	22	2025-12-16	19	15
8	23	2025-12-17	24	30
9	24	2025-12-18	30	33
10	25	2025-12-19	15	10
11	26	2025-12-20	12	9
12	27	2025-12-21	28	26
13	28	2025-12-22	29	20
14	29	2025-12-23	35	30
15	30	2025-12-24	25	21
\.


--
-- TOC entry 5148 (class 0 OID 22885)
-- Dependencies: 233
-- Data for Name: notas_tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notas_tests (idtest, idestudiante, aprobado, fecha, duracion_minutos, num_fallos) FROM stdin;
1	16	t	2025-12-10	20	1
2	17	t	2025-12-11	18	0
3	18	f	2025-12-12	25	7
4	19	f	2025-12-13	15	8
5	20	t	2025-12-14	30	2
6	21	t	2025-12-15	19	1
7	22	f	2025-12-16	14	5
8	23	t	2025-12-17	21	2
9	24	t	2025-12-18	10	0
10	25	f	2025-12-19	29	6
11	26	t	2025-12-20	17	1
12	27	t	2025-12-21	23	2
13	28	f	2025-12-22	13	4
14	29	t	2025-12-23	26	2
15	30	t	2025-12-24	20	1
\.


--
-- TOC entry 5135 (class 0 OID 22754)
-- Dependencies: 220
-- Data for Name: personas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personas (idpersona, nombre, apellido1, apellido2, dni, fecha_nac, direccion, telefono) FROM stdin;
1	Anxo	Curras	\N	12345678X	2000-11-10	Calle Calvar 99	123 456 789
2	Angel	Mendez	\N	87654321Z	1999-07-11	Calle Pilar 87	222 222 222
3	Xurxo	Fisterra	Sotelo	24681357R	1998-02-12	Calle Santarosa 14	333 333 333
4	Jorge	Lago	Cordeiro	78945612T	1996-04-13	Calle Eduardo Chaves 69	444 444 444
5	Miguel	Chaves	Gonzales	32165498Y	1997-09-14	Calle Piñeiro 3	555 555 555
6	Pepe	Del Rio	\N	15975346H	1988-01-15	Calle Calvar 1	666 666 666
7	Manuel	Magallanes	\N	46829715L	1985-03-16	Calle Piñeiro 33	777 777 777
8	Xian	Pazo	Quente	90753124M	1990-05-17	Calle Santarosa 66	888 888 888
9	Juan	Soto	Silva	58241976K	1989-06-18	Calle Eduardo Chaves 9	999 999 999
10	Marta	Reina	\N	73486219P	1991-08-19	Calle Pilar 87	111 111 111
11	Noa	Varela	\N	11223344A	1993-10-20	Rua do Sol 7	111 222 333
12	Iria	Dominguez	Lopez	22334455B	1992-12-21	Avd Galicia 12	222 333 444
13	Hugo	Pereira	\N	33445566C	1987-11-22	Rua Nova 5	333 444 555
14	Lara	Suarez	Mato	44556677D	1994-02-23	Calle Palmas 3	444 555 666
15	Brais	Molina	\N	55667788E	1986-07-24	Rua San Xoan 10	555 666 777
16	Sebas	Vazques	Rios	11112222T	2008-11-15	Calle Calvar 1	666 666 666
17	Aron	Martinez	\N	33334444R	2008-11-16	Calle Pilar 8771	777 777 777
18	Marcos	Antepazo	Ferradas	55556666Y	2008-11-17	Calle Santarosa 87	888 888 888
19	Alejandro	Perez	\N	77778888Q	2008-11-18	Calle Eduardo Chaves 13	999 999 999
20	Javi	Pucelas	Pereira	99998765S	2008-11-19	Calle Piñeiro 45	111 999 555
21	Nerea	Santos	\N	66778899F	2007-01-05	Rua do Regueiro 15	600 000 001
22	Adrian	Gomez	Paz	77889900G	2007-02-06	Rua do Regueiro 15	600 000 002
23	Lucia	Rodriguez	\N	88990011I	2007-03-07	Rua do Regueiro 15	600 000 003
24	Pablo	Alvarez	Seoane	99001122J	2007-04-08	Rua do Regueiro 15	600 000 004
25	Sara	Prieto	\N	10101010K	2007-05-09	Rua do Regueiro 15	600 000 005
26	Diego	Vazquez	\N	20202020L	2007-06-10	Calle Calvar 22	600 000 006
27	Ainhoa	Crespo	Lage	30303030M	2007-07-11	Calle Calvar 23	600 000 007
28	Izan	Nogueira	\N	40404040N	2007-08-12	Calle Calvar 24	600 000 008
29	Carla	Souto	Pita	50505050O	2007-09-13	Calle Calvar 25	600 000 009
30	Eric	Vidal	\N	60606060R	2007-10-14	Calle Calvar 26	600 000 010
\.


--
-- TOC entry 5147 (class 0 OID 22858)
-- Dependencies: 232
-- Data for Name: practicas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.practicas (idpractica, idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos, observaciones) FROM stdin;
1	16	1	1	2025-12-01	60	Circuito básico
2	16	2	2	2025-12-02	55	Arranque en pendiente
3	18	3	3	2025-12-03	50	Rotondas
4	19	4	4	2025-12-04	65	Incorporaciones
5	21	5	5	2025-12-05	45	Señalización
6	21	6	6	2025-12-06	60	Maniobras
7	22	7	7	2025-12-07	70	Autovía
8	23	8	8	2025-12-08	55	Ciudad
9	25	9	9	2025-12-09	50	Estacionamiento
10	25	10	10	2025-12-10	65	Conducción nocturna
11	26	11	11	2025-12-11	60	Glorietas
12	27	12	12	2025-12-12	45	Cambio de carril
13	28	13	13	2025-12-13	75	Autopista
14	29	14	14	2025-12-14	50	Cruces
15	30	15	15	2025-12-15	55	Repaso general
16	17	\N	2	2026-01-10	60	\N
17	20	3	3	2026-01-15	55	\N
19	24	\N	5	2026-01-17	45	\N
20	26	\N	7	2026-02-01	90	Práctica revisada
\.


--
-- TOC entry 5141 (class 0 OID 22813)
-- Dependencies: 226
-- Data for Name: tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tests (idtest, cantidad_preguntas, duracion_max_minutos, tema, dispositivo) FROM stdin;
1	25	25	Luces	Movil
2	30	20	Carroceria	Ordenador
3	17	30	Actuación en accidente	Tablet_auto
4	10	12	Emergencias	Movil
5	22	27	Mantenimiento	PC
6	20	20	Señales	Movil
7	15	15	Prioridad de paso	Tablet_auto
8	18	22	Velocidades	Ordenador
9	12	10	Documentación	Movil
10	28	30	Conducción eficiente	PC
11	16	18	Alcohol y drogas	Movil
12	24	25	Adelantamientos	Tablet_auto
13	14	14	Intersecciones	Ordenador
14	26	28	Túneles	PC
15	19	21	Meteorología	Movil
\.


--
-- TOC entry 5138 (class 0 OID 22784)
-- Dependencies: 223
-- Data for Name: vehiculos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehiculos (idvehiculo, matricula, modelo, marca, color) FROM stdin;
1	1111AAA	GTI	Nissan	Negro
2	2222BBB	TDI	Volkswagen	Azul
3	3333CCC	Fiesta	Ford	Blanco
4	4444DDD	Getz	Hyundai	Gris
5	5555EEE	Corolla	Toyota	Rojo
6	6666FFF	Ibiza	SEAT	Blanco
7	7777GGG	Clio	Renault	Gris
8	8888HHH	Corsa	Opel	Azul
9	9999JJJ	Polo	Volkswagen	Negro
10	0000KKK	208	Peugeot	Rojo
11	1212LLL	Focus	Ford	Azul
12	3434MMM	Astra	Opel	Gris
13	5656NNN	i20	Hyundai	Blanco
14	7878PPP	Yaris	Toyota	Negro
15	9090RRR	Golf	Volkswagen	Gris
\.


--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 227
-- Name: examenesp_idexamenp_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.examenesp_idexamenp_seq', 15, true);


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 229
-- Name: examenest_idexament_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.examenest_idexament_seq', 15, true);


--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 236
-- Name: log_practicas_idlog_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_practicas_idlog_seq', 2, true);


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 219
-- Name: personas_idpersona_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personas_idpersona_seq', 30, true);


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 231
-- Name: practicas_idpractica_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.practicas_idpractica_seq', 20, true);


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 225
-- Name: tests_idtest_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tests_idtest_seq', 15, true);


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 222
-- Name: vehiculos_idvehiculo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vehiculos_idvehiculo_seq', 15, true);


--
-- TOC entry 4939 (class 2606 OID 22981)
-- Name: personas dni_unico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT dni_unico UNIQUE (dni);


--
-- TOC entry 4945 (class 2606 OID 22985)
-- Name: empleados dni_unico_empleados; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT dni_unico_empleados UNIQUE (dni);


--
-- TOC entry 4951 (class 2606 OID 22983)
-- Name: estudiantes dni_unico_estudiantes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiantes
    ADD CONSTRAINT dni_unico_estudiantes UNIQUE (dni);


--
-- TOC entry 4955 (class 2606 OID 22840)
-- Name: examenesp examenesp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examenesp
    ADD CONSTRAINT examenesp_pkey PRIMARY KEY (idexamenp);


--
-- TOC entry 4957 (class 2606 OID 22856)
-- Name: examenest examenest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examenest
    ADD CONSTRAINT examenest_pkey PRIMARY KEY (idexament);


--
-- TOC entry 4971 (class 2606 OID 23002)
-- Name: log_practicas log_practicas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_practicas
    ADD CONSTRAINT log_practicas_pkey PRIMARY KEY (idlog);


--
-- TOC entry 4966 (class 2606 OID 22922)
-- Name: notas_examenp notas_examenp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_examenp
    ADD CONSTRAINT notas_examenp_pkey PRIMARY KEY (idexamenp, idestudiante, fecha);


--
-- TOC entry 4969 (class 2606 OID 22954)
-- Name: notas_exament notas_exament_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_exament
    ADD CONSTRAINT notas_exament_pkey PRIMARY KEY (idexament, idestudiante, fecha);


--
-- TOC entry 4963 (class 2606 OID 22897)
-- Name: notas_tests notas_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_tests
    ADD CONSTRAINT notas_tests_pkey PRIMARY KEY (idtest, idestudiante, fecha);


--
-- TOC entry 4941 (class 2606 OID 22769)
-- Name: personas personas_dni_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_dni_key UNIQUE (dni);


--
-- TOC entry 4943 (class 2606 OID 22767)
-- Name: personas personas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_pkey PRIMARY KEY (idpersona);


--
-- TOC entry 4960 (class 2606 OID 22869)
-- Name: practicas practicas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practicas
    ADD CONSTRAINT practicas_pkey PRIMARY KEY (idpractica);


--
-- TOC entry 4953 (class 2606 OID 22826)
-- Name: tests tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_pkey PRIMARY KEY (idtest);


--
-- TOC entry 4947 (class 2606 OID 22793)
-- Name: vehiculos vehiculos_matricula_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculos
    ADD CONSTRAINT vehiculos_matricula_key UNIQUE (matricula);


--
-- TOC entry 4949 (class 2606 OID 22791)
-- Name: vehiculos vehiculos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculos
    ADD CONSTRAINT vehiculos_pkey PRIMARY KEY (idvehiculo);


--
-- TOC entry 4961 (class 1259 OID 22968)
-- Name: idx_notas_tests_estudiante; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notas_tests_estudiante ON public.notas_tests USING btree (idestudiante);


--
-- TOC entry 4964 (class 1259 OID 22967)
-- Name: idx_notasp_estudiante; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notasp_estudiante ON public.notas_examenp USING btree (idestudiante);


--
-- TOC entry 4967 (class 1259 OID 22966)
-- Name: idx_notast_estudiante; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notast_estudiante ON public.notas_exament USING btree (idestudiante);


--
-- TOC entry 4958 (class 1259 OID 22965)
-- Name: idx_practicas_estudiante; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practicas_estudiante ON public.practicas USING btree (idestudiante);


--
-- TOC entry 4985 (class 2620 OID 23005)
-- Name: practicas trg_log_practicas; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_practicas AFTER INSERT OR UPDATE ON public.practicas FOR EACH ROW EXECUTE FUNCTION public.fn_log_practicas();


--
-- TOC entry 4986 (class 2620 OID 22991)
-- Name: practicas trg_validar_instructor; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_instructor BEFORE INSERT ON public.practicas FOR EACH ROW EXECUTE FUNCTION public.fn_validar_instructor();


--
-- TOC entry 4972 (class 2606 OID 22969)
-- Name: empleados empleados_idjefe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_idjefe_fkey FOREIGN KEY (idjefe) REFERENCES public.personas(idpersona);


--
-- TOC entry 4973 (class 2606 OID 22807)
-- Name: estudiantes estudiantes_idvehiculo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiantes
    ADD CONSTRAINT estudiantes_idvehiculo_fkey FOREIGN KEY (idvehiculo) REFERENCES public.vehiculos(idvehiculo) ON DELETE RESTRICT;


--
-- TOC entry 4979 (class 2606 OID 22928)
-- Name: notas_examenp notas_examenp_idestudiante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_examenp
    ADD CONSTRAINT notas_examenp_idestudiante_fkey FOREIGN KEY (idestudiante) REFERENCES public.personas(idpersona) ON DELETE CASCADE;


--
-- TOC entry 4980 (class 2606 OID 22923)
-- Name: notas_examenp notas_examenp_idexamenp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_examenp
    ADD CONSTRAINT notas_examenp_idexamenp_fkey FOREIGN KEY (idexamenp) REFERENCES public.examenesp(idexamenp) ON DELETE CASCADE;


--
-- TOC entry 4981 (class 2606 OID 22933)
-- Name: notas_examenp notas_examenp_idexaminador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_examenp
    ADD CONSTRAINT notas_examenp_idexaminador_fkey FOREIGN KEY (idexaminador) REFERENCES public.personas(idpersona) ON DELETE RESTRICT;


--
-- TOC entry 4982 (class 2606 OID 22938)
-- Name: notas_examenp notas_examenp_idprofesor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_examenp
    ADD CONSTRAINT notas_examenp_idprofesor_fkey FOREIGN KEY (idprofesor) REFERENCES public.personas(idpersona) ON DELETE RESTRICT;


--
-- TOC entry 4983 (class 2606 OID 22960)
-- Name: notas_exament notas_exament_idestudiante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_exament
    ADD CONSTRAINT notas_exament_idestudiante_fkey FOREIGN KEY (idestudiante) REFERENCES public.personas(idpersona) ON DELETE CASCADE;


--
-- TOC entry 4984 (class 2606 OID 22955)
-- Name: notas_exament notas_exament_idexament_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_exament
    ADD CONSTRAINT notas_exament_idexament_fkey FOREIGN KEY (idexament) REFERENCES public.examenest(idexament) ON DELETE CASCADE;


--
-- TOC entry 4977 (class 2606 OID 22903)
-- Name: notas_tests notas_tests_idestudiante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_tests
    ADD CONSTRAINT notas_tests_idestudiante_fkey FOREIGN KEY (idestudiante) REFERENCES public.personas(idpersona) ON DELETE CASCADE;


--
-- TOC entry 4978 (class 2606 OID 22898)
-- Name: notas_tests notas_tests_idtest_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notas_tests
    ADD CONSTRAINT notas_tests_idtest_fkey FOREIGN KEY (idtest) REFERENCES public.tests(idtest) ON DELETE CASCADE;


--
-- TOC entry 4974 (class 2606 OID 22875)
-- Name: practicas practicas_idempleado_instructor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practicas
    ADD CONSTRAINT practicas_idempleado_instructor_fkey FOREIGN KEY (idempleado_instructor) REFERENCES public.personas(idpersona) ON DELETE SET NULL;


--
-- TOC entry 4975 (class 2606 OID 22870)
-- Name: practicas practicas_idestudiante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practicas
    ADD CONSTRAINT practicas_idestudiante_fkey FOREIGN KEY (idestudiante) REFERENCES public.personas(idpersona) ON DELETE CASCADE;


--
-- TOC entry 4976 (class 2606 OID 22880)
-- Name: practicas practicas_idvehiculo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practicas
    ADD CONSTRAINT practicas_idvehiculo_fkey FOREIGN KEY (idvehiculo) REFERENCES public.vehiculos(idvehiculo) ON DELETE SET NULL;


-- Completed on 2026-06-06 18:07:25

--
-- PostgreSQL database dump complete
--

\unrestrict CSL0PQBXftMo6fEdjVTayP4GcWzjaHulC3fJhRAJcV5XZkvgtFe13N3F1QMnGXG

