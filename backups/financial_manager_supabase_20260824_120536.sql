--
-- PostgreSQL database dump
--

\restrict wV0Jx9eQDoR0PeOI8tCju42vyf4NE0QshZLW9jEgfMBQjEJO3vexYkKgISRgqKe

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.4 (Debian 18.4-1.pgdg12+1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    id bigint NOT NULL,
    name character varying,
    number character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    total_limit numeric,
    due_day integer,
    closing_day integer,
    user_id bigint,
    color character varying
);


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cards_id_seq OWNED BY public.cards.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    icon character varying,
    user_id bigint,
    color character varying DEFAULT '#2563EB'::character varying NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expenses (
    id bigint NOT NULL,
    amount numeric,
    date date,
    balance_month date,
    description character varying,
    category_id bigint NOT NULL,
    card_id bigint,
    payment_method integer,
    paid boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    installments_count integer DEFAULT 1 NOT NULL,
    current_installment integer DEFAULT 1 NOT NULL,
    installment_group_id bigint,
    paid_at timestamp(6) without time zone,
    user_id bigint
);


--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.expenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


--
-- Name: financial_goal_resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.financial_goal_resources (
    id bigint NOT NULL,
    financial_goal_id integer NOT NULL,
    resource_type integer DEFAULT 0 NOT NULL,
    description character varying NOT NULL,
    amount numeric(12,2) DEFAULT 0.0 NOT NULL,
    include_in_total boolean DEFAULT true NOT NULL,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    source_type character varying,
    source_id bigint
);


--
-- Name: financial_goal_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.financial_goal_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: financial_goal_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.financial_goal_resources_id_seq OWNED BY public.financial_goal_resources.id;


--
-- Name: financial_goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.financial_goals (
    id bigint NOT NULL,
    description character varying NOT NULL,
    target_amount numeric(12,2) NOT NULL,
    due_date date NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 1 NOT NULL,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    current_amount numeric(12,2) DEFAULT 0.0 NOT NULL,
    category_id integer,
    user_id bigint,
    color character varying
);


--
-- Name: financial_goals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.financial_goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: financial_goals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.financial_goals_id_seq OWNED BY public.financial_goals.id;


--
-- Name: incomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incomes (
    id bigint NOT NULL,
    amount numeric,
    date date,
    balance_month date,
    description character varying,
    paid boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    category_id bigint,
    user_id bigint
);


--
-- Name: incomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incomes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incomes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incomes_id_seq OWNED BY public.incomes.id;


--
-- Name: passkey_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passkey_credentials (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    webauthn_id character varying NOT NULL,
    public_key text NOT NULL,
    sign_count integer DEFAULT 0 NOT NULL,
    nickname character varying,
    last_used_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: passkey_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.passkey_credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passkey_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.passkey_credentials_id_seq OWNED BY public.passkey_credentials.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    password_digest character varying DEFAULT ''::character varying NOT NULL,
    webauthn_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    remember_created_at timestamp(6) without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards ALTER COLUMN id SET DEFAULT nextval('public.cards_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Name: financial_goal_resources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_goal_resources ALTER COLUMN id SET DEFAULT nextval('public.financial_goal_resources_id_seq'::regclass);


--
-- Name: financial_goals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_goals ALTER COLUMN id SET DEFAULT nextval('public.financial_goals_id_seq'::regclass);


--
-- Name: incomes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incomes ALTER COLUMN id SET DEFAULT nextval('public.incomes_id_seq'::regclass);


--
-- Name: passkey_credentials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_credentials ALTER COLUMN id SET DEFAULT nextval('public.passkey_credentials_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_attachments (id, name, record_type, record_id, blob_id, created_at) FROM stdin;
14	icon	Card	10	14	2026-05-01 00:51:20.786491
15	icon	Card	8	15	2026-05-01 00:51:33.648751
16	icon	Card	5	16	2026-05-01 00:52:18.994223
17	icon	Card	9	17	2026-05-01 00:54:55.096697
18	icon	Card	6	18	2026-05-01 00:55:22.118063
21	icon	Card	7	21	2026-05-08 16:33:19.830795
22	icon	Card	11	22	2026-06-09 19:06:42.034836
23	icon	Card	12	23	2026-06-16 15:37:51.072445
\.


--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_blobs (id, key, filename, content_type, metadata, service_name, byte_size, checksum, created_at) FROM stdin;
1	nqyepr3pg5tbb6mg86u2loxm9244	673524.webp	image/webp	{"identified":true,"analyzed":true}	local	237468	SjBpOgtgX5bdeFmQzdPasQ==	2026-04-18 21:43:52.156991
2	9ivbi5vgpzedtxvylxkelxva2ohp	logo_sicoob_kk2l4J.png	image/png	{"identified":true,"analyzed":true}	local	6147	X9pS9vaOkL4VR0EtzNyNnQ==	2026-04-18 21:45:45.44638
3	t9mx4z57tv24kqq5ydgfa93keucv	cartao-amazon-prime-amazon-com-br.jpg.webp	image/webp	{"identified":true,"analyzed":true}	local	43872	2K3nZmLDGcu9hjx7vTqHdQ==	2026-04-18 21:47:32.937493
4	aakjc6i2961sxilg6s6qakes7sc3	118435080_3160881097294259_2075488246104850780_n.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	40391	plOpecMqChydG9aZAE3nFw==	2026-04-19 14:46:43.438327
5	vebfffh6rg13bwnfvr1y8ywga0yl	2233-pt_BR-small-perfi_loja.png	image/png	{"identified":true,"analyzed":true}	local	21834	LEPT9J82Aft4bvELis6c2g==	2026-04-19 14:47:22.842538
6	dnld7wx27vfppo33o4bgfpg5iev1	cea_1704907027___Bmb06S26gXH0i8umQ_zAG.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	15226	ryyOsJ4zA5PaWRjltMQqtA==	2026-04-21 16:53:03.878953
7	at787hs8mywzdji2fvfp36oghmdd	cartao-amazon-prime-amazon-com-br.jpg.webp	image/webp	{"identified":true}	local	43872	2K3nZmLDGcu9hjx7vTqHdQ==	2026-05-01 00:33:29.967508
8	zgf347hji3oyy6pfmcl8ixhbr3uj	cea_1704907027___Bmb06S26gXH0i8umQ_zAG.jpg	image/jpeg	{"identified":true}	local	15226	ryyOsJ4zA5PaWRjltMQqtA==	2026-05-01 00:34:02.288797
9	yjuey8yjm9vqc3agz4zbqmu1moy7	118435080_3160881097294259_2075488246104850780_n.jpeg	image/jpeg	{"identified":true}	local	40391	plOpecMqChydG9aZAE3nFw==	2026-05-01 00:34:11.634555
10	hrzbmyeht3350km42dzx5p1okgjx	673524.webp	image/webp	{"identified":true}	local	237468	SjBpOgtgX5bdeFmQzdPasQ==	2026-05-01 00:34:25.376571
11	8l6latbevujlclwuxsmabewbu4js	2233-pt_BR-small-perfi_loja.png	image/png	{"identified":true}	local	21834	LEPT9J82Aft4bvELis6c2g==	2026-05-01 00:34:34.287514
12	i489yly4g6mlnlquu0r1l7mn88gm	logo_sicoob_kk2l4J.png	image/png	{"identified":true}	local	6147	X9pS9vaOkL4VR0EtzNyNnQ==	2026-05-01 00:34:47.745323
13	1i2zh6ylaedkey3rphk0vcvy5msl	cartao-amazon-prime-amazon-com-br.jpg.webp	image/webp	{"identified":true}	supabase	43872	2K3nZmLDGcu9hjx7vTqHdQ==	2026-05-01 00:49:59.274825
14	hw97kf9gqvcsrr88i8jvo2lha5et	cea_1704907027___Bmb06S26gXH0i8umQ_zAG.jpg	image/jpeg	{"identified":true}	supabase	15226	ryyOsJ4zA5PaWRjltMQqtA==	2026-05-01 00:51:20.783664
15	7whivotpvovk0ki2hk7ulyg5fwu5	118435080_3160881097294259_2075488246104850780_n.jpeg	image/jpeg	{"identified":true}	supabase	40391	plOpecMqChydG9aZAE3nFw==	2026-05-01 00:51:33.645447
16	zynyoecpkttgc4zaerfi0hl56x31	673524.webp	image/webp	{"identified":true}	supabase	237468	SjBpOgtgX5bdeFmQzdPasQ==	2026-05-01 00:52:18.991363
17	nx307o7rwzv1xqgxzcioh20w37w4	2233-pt_BR-small-perfi_loja.png	image/png	{"identified":true}	supabase	21834	LEPT9J82Aft4bvELis6c2g==	2026-05-01 00:54:55.093301
18	1qqngdc3b5t8lr4uas3fcwsjj6ua	logo_sicoob_kk2l4J.png	image/png	{"identified":true}	supabase	6147	X9pS9vaOkL4VR0EtzNyNnQ==	2026-05-01 00:55:22.115146
21	qxgz8v5pzn1sv80li9apy7xb8m3j	amazon-logo-amazon-icon-free-free-vector.jpg	image/jpeg	{"identified":true,"analyzed":true}	supabase	10897	fm/UxLRu9zUA2WPf0gmfFQ==	2026-05-08 16:33:19.826738
22	adh6blqv78i4xks0h1a90231h2nk	cartao-de-credito-santander-free.jpg	image/jpeg	{"identified":true,"analyzed":true}	supabase	39231	DEno91INKSQdswbCzSMxCA==	2026-06-09 19:06:41.953589
23	xes3owbhs73biyy92y61b3ops76e	53723.png	image/png	{"identified":true,"analyzed":true}	supabase	12677	66eVzU8EjDNsz7HmbX2NzQ==	2026-06-16 15:37:51.061192
\.


--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_variant_records (id, blob_id, variation_digest) FROM stdin;
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	production	2026-04-30 15:26:23.146648	2026-04-30 15:26:23.146653
schema_sha1	b08711529948796b1a170dbf8c06e6b4005a579f	2026-04-30 15:26:23.158322	2026-04-30 15:26:23.158379
\.


--
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cards (id, name, number, created_at, updated_at, total_limit, due_day, closing_day, user_id, color) FROM stdin;
10	C&A		2026-04-21 16:53:03.870213	2026-05-07 22:58:11.098563	940	3	21	1	#DC2626
9	PicPay		2026-04-19 14:47:22.836173	2026-05-07 22:58:41.372338	8970	5	29	1	#16A34A
6	Sicoob		2026-04-18 21:44:02.588103	2026-05-07 22:58:52.83761	15000	7	27	1	#0F766E
8	Caixa		2026-04-19 14:46:43.427067	2026-06-07 17:13:05.375714	8000	8	28	1	#2563EB
5	Mercado Pago		2026-04-18 21:43:52.121582	2026-06-07 17:13:09.636194	2500	4	29	1	#F0C510
7	Amazon		2026-04-18 21:47:25.935185	2026-06-07 17:13:25.278484	6000	5	21	1	#6B7280
11	Santander		2026-06-09 19:06:41.735589	2026-06-09 19:06:42.754384	357.0	13	1	1	#DC2626
12	Neon		2026-06-16 15:37:50.775465	2026-06-16 15:37:51.586738	1000.0	5	29	1	#0891B2
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, created_at, updated_at, icon, user_id, color) FROM stdin;
19	Hobbies, Terapias e Bem-estar	2025-10-05 05:05:53.690181	2026-06-04 13:52:22.190792	self_improvement	1	#0F766E
6	Conta de Água e Esgoto	2025-10-05 05:05:53.606242	2026-05-07 22:13:48.205366	water_drop	1	#0891B2
44	Doações e Caridade	2025-10-05 05:05:53.828763	2026-05-07 22:13:48.205366	volunteer_activism	1	#16A34A
38	Eletrônicos e Eletrodomésticos	2025-10-05 05:05:53.797723	2026-05-07 22:13:48.205366	devices	1	#0891B2
30	Empréstimos e Financiamentos	2025-10-05 05:05:53.755319	2026-05-07 22:13:48.205366	request_quote	1	#DC2626
45	Impostos e Taxas	2025-10-05 05:05:53.833961	2026-05-07 22:13:48.205366	receipt_long	1	#DC2626
29	Investimentos	2025-10-05 05:05:53.750037	2026-05-07 22:13:48.205366	trending_up	1	#16A34A
12	Lanches e Fast Food	2025-10-05 05:05:53.64648	2026-05-07 22:13:48.205366	fastfood	1	#EA580C
10	Manutenção do Carro	2025-10-05 05:05:53.635514	2026-05-07 22:13:48.205366	car_repair	1	#EA580C
41	Pets	2025-10-05 05:05:53.812617	2026-05-07 22:13:48.205366	pets	1	#16A34A
17	Plano de Saúde	2025-10-05 05:05:53.68022	2026-05-07 22:13:48.205366	health_and_safety	1	#0F766E
14	Restaurantes	2025-10-05 05:05:53.657535	2026-05-07 22:13:48.205366	restaurant	1	#EA580C
26	Viagens	2025-10-05 05:05:53.732795	2026-05-07 22:13:48.205366	flight	1	#0891B2
87	Estornos e Restituições	2026-05-12 13:18:09.898248	2026-05-12 13:18:09.898248		1	#16A34A
3	Aluguel	2025-10-04 22:16:10.335635	2026-06-04 13:04:34.314128	home	1	#DC2626
9	Aplicativos de Viagem	2025-10-05 05:05:53.630102	2026-06-04 13:43:59.309128	local_taxi	1	#F0C510
49	Cuidados e Limpeza Domésticos	2025-10-05 05:05:53.855073	2026-06-04 13:45:13.90168	cleaning_services	1	#AB7743
13	Cafés e Bebidas	2025-10-05 05:05:53.652462	2026-06-04 13:45:28.055409	local_cafe	1	#AB7743
8	Combustível	2025-10-05 05:05:53.616764	2026-06-04 13:45:36.314146	local_gas_station	1	#6B7280
5	Conta de Luz	2025-10-05 05:05:53.60079	2026-06-04 13:45:52.759723	lightbulb	1	#F0C510
20	Cursos, Livros e Papelaria	2025-10-05 05:05:53.695695	2026-06-04 13:46:58.55373	menu_book	1	#7C3AED
15	Medicamentos	2025-10-05 05:05:53.662284	2026-06-04 13:47:20.203577	medication	1	#16A34A
54	Obras e Manutenção	2026-04-21 13:47:09.495936	2026-06-04 13:48:09.44497	add_home_work	1	#AB7743
2	Outros	2025-01-10 00:00:00	2026-06-04 13:48:13.791258	category	1	#6B7280
53	Previsão de Gastos	2026-04-21 04:21:57.567221	2026-06-04 13:48:24.64644	bar_chart_4_bars	1	#6B7280
31	Roupas, Calçados e Acessórios	2025-10-05 05:05:53.760447	2026-06-04 13:48:40.004232	checkroom	1	#7C3AED
46	Seguros	2025-10-05 05:05:53.838843	2026-06-04 13:48:45.813834	shield	1	#2563EB
52	Salário	2026-04-20 15:54:34.621311	2026-06-04 13:49:36.134419	money_bag	1	#F0C510
11	Supermercado	2025-10-05 05:05:53.640855	2026-06-04 13:49:43.158638	shopping_cart	1	#DC2626
55	Utensílios Domésticos	2026-04-21 13:49:30.701406	2026-06-04 13:50:05.936505	food_bank	1	#2563EB
24	Jogos	2025-10-05 05:05:53.722278	2026-06-04 13:50:52.498351	sports_esports	1	#F0C510
43	Presentes, Festas e Eventos	2025-10-05 05:05:53.823418	2026-06-04 13:51:53.437602	redeem	1	#DB2777
16	Consultas Médicas e Odontológicas	2025-10-05 05:05:53.674628	2026-05-07 22:15:55.807106	medical_services	1	#16A34A
18	Academia, Fitness e Esportes	2025-10-05 05:05:53.685032	2026-06-04 13:42:16.349619	fitness_center	1	#2563EB
28	Bancos e Tarifas	2025-10-05 05:05:53.742887	2026-06-04 13:45:06.445529	account_balance	1	#AB7743
34	Beleza e Cuidados Pessoais	2025-10-05 05:05:53.776183	2026-06-04 13:45:23.733393	spa	1	#DB2777
37	Conta de Internet	2025-10-05 05:05:53.792438	2026-06-04 13:45:47.840929	wifi	1	#6B7280
48	Assinaturas e Serviços	2025-10-05 05:05:53.849106	2026-05-07 22:13:48.205366	subscriptions	1	#EA580C
36	Celular e Planos	2025-10-05 05:05:53.787076	2026-05-07 22:13:48.205366	smartphone	1	#0891B2
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.expenses (id, amount, date, balance_month, description, category_id, card_id, payment_method, paid, created_at, updated_at, installments_count, current_installment, installment_group_id, paid_at, user_id) FROM stdin;
954	216.0	2026-05-08	2026-06-01	Consignado Alfa 2	30	\N	1	t	2026-05-08 22:11:54.163621	2026-05-29 11:12:15.143575	1	1	\N	2026-05-29 11:12:15.143521	1
1624	145.08	2026-08-20	2026-08-20	Combustivel	8	\N	0	t	2026-08-21 12:40:22.947571	2026-08-21 12:40:22.947571	1	1	\N	2026-08-21 12:40:22.947537	1
944	270.0	2026-09-12	2026-09-12	Seguro	46	\N	1	f	2026-05-02 01:23:31.517513	2026-05-02 01:23:31.517513	1	1	\N	\N	1
945	270.0	2026-10-12	2026-10-12	Seguro	46	\N	1	f	2026-05-02 01:23:31.594	2026-05-02 01:23:31.594	1	1	\N	\N	1
946	270.0	2026-11-12	2026-11-12	Seguro	46	\N	1	f	2026-05-02 01:23:31.600237	2026-05-02 01:23:31.600237	1	1	\N	\N	1
593	1612.94	2026-06-01	2026-06-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:09.106689	2026-05-29 11:12:29.190548	1	1	\N	2026-05-29 11:12:29.190479	1
465	3223.79	2026-06-01	2026-06-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:08.784616	2026-05-29 11:12:35.962701	1	1	\N	2026-05-29 11:12:35.96264	1
947	270.0	2026-12-12	2026-12-12	Seguro	46	\N	1	f	2026-05-02 01:23:31.609153	2026-05-02 01:23:47.551044	1	1	\N	\N	1
940	270.0	2026-05-12	2026-05-12	Seguro	46	\N	1	t	2026-05-02 01:23:31.312675	2026-05-02 01:23:51.153958	1	1	\N	2026-05-02 01:23:51.153882	1
941	270.0	2026-06-12	2026-06-12	Seguro	46	\N	1	t	2026-05-02 01:23:31.43206	2026-06-02 21:46:09.230004	1	1	\N	2026-06-02 21:46:09.229925	1
1059	700.0	2026-05-10	2026-05-10	Perfumes	34	\N	0	t	2026-05-11 14:23:11.888393	2026-05-11 14:24:43.457601	1	1	\N	2026-05-11 14:24:43.456474	1
697	725.33	2026-05-05	2026-05-05	Sicoob Emprestimo	30	\N	1	t	2026-04-21 04:08:09.397988	2026-05-11 14:24:47.767245	1	1	\N	2026-05-11 14:24:47.767172	1
1216	540.0	2026-05-25	2026-05-25	Concertina 	54	\N	0	t	2026-05-26 18:52:21.966161	2026-05-26 18:52:25.414001	1	1	\N	2026-05-26 18:52:25.413934	1
426	220.0	2026-06-11	2026-06-11	Internet	37	\N	1	t	2026-04-21 04:01:20.959784	2026-06-02 22:14:45.220036	1	1	\N	2026-06-02 22:13:47.492907	1
1436	140.0	2026-06-14	2026-09-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.667465	2026-06-14 21:35:38.667465	10	3	1434	\N	1
1437	140.0	2026-06-14	2026-10-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.743561	2026-06-14 21:35:38.743561	10	4	1434	\N	1
1438	140.0	2026-06-14	2026-11-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.748254	2026-06-14 21:35:38.748254	10	5	1434	\N	1
1439	140.0	2026-06-14	2026-12-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.752442	2026-06-14 21:35:38.752442	10	6	1434	\N	1
1440	140.0	2026-06-14	2027-01-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.755972	2026-06-14 21:35:38.755972	10	7	1434	\N	1
1441	140.0	2026-06-14	2027-02-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.759642	2026-06-14 21:35:38.759642	10	8	1434	\N	1
1442	140.0	2026-06-14	2027-03-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.763316	2026-06-14 21:35:38.763316	10	9	1434	\N	1
1443	140.0	2026-06-14	2027-04-07	Pix no Crédito Sicoob	30	6	3	f	2026-06-14 21:35:38.767625	2026-06-14 21:35:38.767625	10	10	1434	\N	1
1446	50.0	2026-06-14	2026-09-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.857915	2026-06-14 21:35:38.857915	10	3	1444	\N	1
1447	50.0	2026-06-14	2026-10-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.861584	2026-06-14 21:35:38.861584	10	4	1444	\N	1
1448	50.0	2026-06-14	2026-11-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.865284	2026-06-14 21:35:38.865284	10	5	1444	\N	1
1449	50.0	2026-06-14	2026-12-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.869859	2026-06-14 21:35:38.869859	10	6	1444	\N	1
1450	50.0	2026-06-14	2027-01-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.873911	2026-06-14 21:35:38.873911	10	7	1444	\N	1
1451	50.0	2026-06-14	2027-02-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.877576	2026-06-14 21:35:38.877576	10	8	1444	\N	1
1452	50.0	2026-06-14	2027-03-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.880878	2026-06-14 21:35:38.880878	10	9	1444	\N	1
1453	50.0	2026-06-14	2027-04-08	Pix no Crédito Caixa	30	8	3	f	2026-06-14 21:35:38.944807	2026-06-14 21:35:38.944807	10	10	1444	\N	1
1456	50.0	2026-06-14	2026-09-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:38.966802	2026-06-14 21:35:38.966802	10	3	1454	\N	1
1457	50.0	2026-06-14	2026-10-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:38.973089	2026-06-14 21:35:38.973089	10	4	1454	\N	1
1458	50.0	2026-06-14	2026-11-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:39.040007	2026-06-14 21:35:39.040007	10	5	1454	\N	1
1459	50.0	2026-06-14	2026-12-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:39.045265	2026-06-14 21:35:39.045265	10	6	1454	\N	1
1460	50.0	2026-06-14	2027-01-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:39.055361	2026-06-14 21:35:39.055361	10	7	1454	\N	1
1461	50.0	2026-06-14	2027-02-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:39.060771	2026-06-14 21:35:39.060771	10	8	1454	\N	1
1462	50.0	2026-06-14	2027-03-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:39.064643	2026-06-14 21:35:39.064643	10	9	1454	\N	1
1463	50.0	2026-06-14	2027-04-05	Pix no Crédito Amazon	30	7	3	f	2026-06-14 21:35:39.142332	2026-06-14 21:35:39.142332	10	10	1454	\N	1
1434	140.0	2026-06-14	2026-07-07	Pix no Crédito Sicoob	30	6	3	t	2026-06-14 21:35:38.611541	2026-06-29 19:58:08.32952	10	1	1434	2026-06-29 19:58:08.329445	1
1444	50.0	2026-06-14	2026-07-08	Pix no Crédito Caixa	30	8	3	t	2026-06-14 21:35:38.843185	2026-06-29 19:58:32.213252	10	1	1444	2026-06-29 19:58:32.213172	1
1454	50.0	2026-06-14	2026-07-05	Pix no Crédito Amazon	30	7	3	t	2026-06-14 21:35:38.951762	2026-06-29 19:59:00.676176	10	1	1454	2026-06-29 19:59:00.676112	1
1113	20.49	2026-05-22	2026-07-05	Pratiko	12	7	2	t	2026-05-22 19:38:01.290227	2026-06-29 19:59:15.508936	1	1	\N	2026-06-29 19:59:15.508879	1
594	1612.94	2026-07-01	2026-07-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:09.108902	2026-06-29 20:05:34.179904	1	1	\N	2026-06-29 20:05:34.179839	1
942	270.0	2026-07-12	2026-07-12	Seguro	46	\N	1	t	2026-05-02 01:23:31.498201	2026-07-02 00:17:39.73374	1	1	\N	2026-07-02 00:17:39.733671	1
1523	125.0	2026-07-08	2027-03-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.19854	2026-07-11 12:56:47.19854	12	8	1516	\N	1
1524	125.0	2026-07-08	2027-04-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.202512	2026-07-11 12:56:47.202512	12	9	1516	\N	1
1525	125.0	2026-07-08	2027-05-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.205652	2026-07-11 12:56:47.205652	12	10	1516	\N	1
1526	125.0	2026-07-08	2027-06-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.208701	2026-07-11 12:56:47.208701	12	11	1516	\N	1
1527	125.0	2026-07-08	2027-07-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.21179	2026-07-11 12:56:47.21179	12	12	1516	\N	1
1529	100.0	2026-07-09	2026-09-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.2246	2026-07-11 12:56:47.2246	10	2	1528	\N	1
1530	100.0	2026-07-09	2026-10-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.22735	2026-07-11 12:56:47.22735	10	3	1528	\N	1
1592	361.79	2026-07-28	2026-07-28	Rede Stores	11	\N	0	t	2026-08-04 13:17:21.927592	2026-08-04 13:17:28.555665	1	1	\N	2026-08-04 13:17:28.554582	1
1593	585.81	2026-07-30	2026-07-30	Filtro	38	\N	0	t	2026-08-04 13:18:04.450868	2026-08-04 13:18:04.450868	1	1	\N	2026-08-04 13:18:04.450431	1
1455	50.0	2026-06-14	2026-08-05	Pix no Crédito Amazon	30	7	3	t	2026-06-14 21:35:38.962893	2026-08-04 13:20:28.742767	10	2	1454	2026-08-04 13:20:28.742767	1
1435	140.0	2026-06-14	2026-08-07	Pix no Crédito Sicoob	30	6	3	t	2026-06-14 21:35:38.659577	2026-08-04 13:20:38.973086	10	2	1434	2026-08-04 13:20:38.973086	1
943	270.0	2026-08-12	2026-08-12	Seguro	46	\N	1	t	2026-05-02 01:23:31.505034	2026-08-14 16:08:26.250357	1	1	\N	2026-08-14 16:08:26.250198	1
325	333.33	2026-02-02	2026-05-05	Pix no Crédito	30	9	3	t	2026-04-21 03:44:47.476028	2026-05-02 16:21:30.94344	12	3	325	2026-05-02 16:21:30.94344	1
337	203.51	2025-06-18	2026-05-05	Pix no Crédito	30	9	3	t	2026-04-21 03:44:47.51378	2026-05-02 16:21:30.94344	12	11	337	2026-05-02 16:21:30.94344	1
458	180	2026-07-01	2026-07-01	INSS Mãe	45	\N	1	t	2026-04-21 04:01:21.051419	2026-08-21 12:49:00.213506	1	1	\N	2026-08-21 12:49:00.213426	1
162	263.56	2026-04-11	2026-05-04	Bota (Cancelada mas vai cobrar)	49	5	2	t	2026-04-21 02:51:17.929842	2026-05-02 16:24:31.874246	1	1	\N	2026-05-02 16:24:31.874246	1
302	17.3	2026-03-31	2026-05-04	Cafe	11	5	3	t	2026-04-21 03:44:47.357465	2026-05-02 16:24:31.874246	6	1	302	2026-05-02 16:24:31.874246	1
308	14.97	2026-03-23	2026-05-04	Psyllium	18	5	3	t	2026-04-21 03:44:47.377154	2026-05-02 16:24:31.874246	4	2	308	2026-05-02 16:24:31.874246	1
311	30.25	2026-01-09	2026-05-04	Pia	54	5	3	t	2026-04-21 03:44:47.392779	2026-05-02 16:24:31.874246	8	4	311	2026-05-02 16:24:31.874246	1
316	40.18	2025-11-20	2026-05-04	Cabos	54	5	3	t	2026-04-21 03:44:47.410378	2026-05-02 16:24:31.874246	6	6	316	2026-05-02 16:24:31.874246	1
403	198.49	2026-03-31	2026-05-04	Produtos de Lavar roupa	49	5	2	t	2026-04-21 03:53:15.734108	2026-05-02 16:24:31.874246	1	1	\N	2026-05-02 16:24:31.874246	1
323	65.08	2026-03-25	2026-05-05	Remédios	15	9	3	t	2026-04-21 03:44:47.460477	2026-05-12 12:33:47.294695	3	2	323	2026-05-02 16:21:30.94344	1
320	66.24	2026-04-05	2026-05-05	Lençol	49	9	3	t	2026-04-21 03:44:47.438235	2026-05-12 12:34:13.87292	3	1	320	2026-05-02 16:21:30.94344	1
294	28.91	2026-04-12	2026-05-04	Bota	31	5	3	t	2026-04-21 03:44:47.326489	2026-06-04 13:43:14.584721	8	1	294	2026-05-02 16:24:31.874246	1
948	103.5	2026-03-24	2026-05-04	ChatGPT	48	5	2	t	2026-05-02 16:23:38.830846	2026-06-04 13:44:46.13033	1	1	\N	2026-05-02 16:24:31.874246	1
163	158.8	2026-04-10	2026-05-04	Meli+	48	5	2	t	2026-04-21 02:51:17.947845	2026-06-04 13:49:07.097253	1	1	\N	2026-05-02 16:24:31.874246	1
164	19.9	2026-04-07	2026-05-04	EBN *CRUNCHYROLL	48	5	2	t	2026-04-21 02:51:17.950178	2026-06-04 13:49:12.253759	1	1	\N	2026-05-02 16:24:31.874246	1
1464	159.32	2026-06-11	2026-06-11	Pisos que faltaram	54	\N	0	t	2026-06-14 21:43:24.863985	2026-06-14 21:43:39.542405	1	1	\N	2026-06-14 21:43:39.541851	1
1465	159.32	2026-06-12	2026-06-12	Pisos que faltaram	54	\N	0	t	2026-06-14 21:43:24.873797	2026-06-14 21:43:42.778537	1	1	\N	2026-06-14 21:43:42.778469	1
1466	12.7	2026-06-12	2026-06-12	Pequi Net	37	\N	0	t	2026-06-14 21:44:32.948147	2026-06-14 21:44:32.948147	1	1	\N	2026-06-14 21:44:32.948107	1
1467	570.0	2026-06-08	2026-06-08	Materiais Complementares	54	\N	0	t	2026-06-14 21:46:12.027848	2026-06-14 21:46:32.526954	1	1	\N	2026-06-14 21:46:32.526882	1
1344	250.0	2026-06-03	2026-07-05	Pix no crédito Pic Pay	54	9	3	t	2026-06-03 18:16:20.869482	2026-07-02 00:03:43.876536	10	1	1344	2026-07-02 00:03:43.876536	1
1531	100.0	2026-07-09	2026-11-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.289814	2026-07-11 12:56:47.289814	10	4	1528	\N	1
1532	100.0	2026-07-09	2026-12-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.293574	2026-07-11 12:56:47.293574	10	5	1528	\N	1
1533	100.0	2026-07-09	2027-01-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.296657	2026-07-11 12:56:47.296657	10	6	1528	\N	1
1534	100.0	2026-07-09	2027-02-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.299135	2026-07-11 12:56:47.299135	10	7	1528	\N	1
1535	100.0	2026-07-09	2027-03-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.301738	2026-07-11 12:56:47.301738	10	8	1528	\N	1
1536	100.0	2026-07-09	2027-04-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.304331	2026-07-11 12:56:47.304331	10	9	1528	\N	1
1537	100.0	2026-07-09	2027-05-05	Pix no Crédito Neon	54	12	3	f	2026-07-11 12:56:47.306854	2026-07-11 12:56:47.306854	10	10	1528	\N	1
1539	83.37	2026-07-08	2026-09-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.322508	2026-07-11 12:56:47.322508	12	2	1538	\N	1
1540	83.37	2026-07-08	2026-10-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.325232	2026-07-11 12:56:47.325232	12	3	1538	\N	1
1541	83.37	2026-07-08	2026-11-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.327722	2026-07-11 12:56:47.327722	12	4	1538	\N	1
1542	83.37	2026-07-08	2026-12-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.330174	2026-07-11 12:56:47.330174	12	5	1538	\N	1
1543	83.37	2026-07-08	2027-01-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.332574	2026-07-11 12:56:47.332574	12	6	1538	\N	1
1544	83.37	2026-07-08	2027-02-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.335029	2026-07-11 12:56:47.335029	12	7	1538	\N	1
1545	83.37	2026-07-08	2027-03-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.389749	2026-07-11 12:56:47.389749	12	8	1538	\N	1
1594	2000.0	2026-07-31	2026-07-31	Caixa Limite	28	\N	0	t	2026-08-04 13:19:38.295887	2026-08-04 13:19:38.295887	1	1	\N	2026-08-04 13:19:38.295829	1
1538	83.37	2026-07-08	2026-08-08	Pix no Crédito Caixa	54	8	3	t	2026-07-11 12:56:47.315336	2026-08-04 13:20:24.419771	12	1	1538	2026-08-04 13:20:24.419771	1
1345	250.0	2026-06-03	2026-08-05	Pix no crédito Pic Pay	54	9	3	t	2026-06-03 18:16:20.976792	2026-08-04 13:20:36.282873	10	2	1344	2026-08-04 13:20:36.282873	1
1488	1200.0	2026-08-01	2026-08-01	Aluguel 	3	\N	0	t	2026-06-29 20:26:19.243864	2026-08-04 13:25:30.562019	1	1	\N	2026-08-04 13:25:30.561935	1
1597	120.0	2026-08-04	2026-08-04	Montagem do Guarda Roupa	54	\N	0	t	2026-08-04 13:33:10.124249	2026-08-14 16:08:46.544074	1	1	\N	2026-08-14 16:08:46.543989	1
1620	1900.0	2026-09-01	2026-09-01	Limite caixa	28	\N	1	f	2026-08-14 16:10:58.4364	2026-08-14 16:10:58.4364	1	1	\N	\N	1
1061	33.73	2026-05-09	2026-06-05	Ifood bolo	12	9	2	t	2026-05-12 12:23:35.82081	2026-05-30 11:29:27.24626	1	1	\N	2026-05-30 11:29:27.245995	1
1060	38.99	2026-05-11	2026-06-05	Remedio	15	9	2	t	2026-05-12 12:23:35.718318	2026-05-30 11:29:43.28635	1	1	\N	2026-05-30 11:29:43.28628	1
949	27.36	2026-05-02	2026-05-02	Energia Casa Nova	5	\N	0	t	2026-05-03 01:15:52.870408	2026-05-03 01:15:52.870408	1	1	\N	2026-05-03 01:15:52.870301	1
1356	500.0	2026-06-03	2026-09-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.370048	2026-06-03 18:29:59.370048	10	3	1354	\N	1
1357	500.0	2026-06-03	2026-10-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.373531	2026-06-03 18:29:59.373531	10	4	1354	\N	1
1358	500.0	2026-06-03	2026-11-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.377099	2026-06-03 18:29:59.377099	10	5	1354	\N	1
1359	500.0	2026-06-03	2026-12-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.380871	2026-06-03 18:29:59.380871	10	6	1354	\N	1
1360	500.0	2026-06-03	2027-01-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.384416	2026-06-03 18:29:59.384416	10	7	1354	\N	1
1361	500.0	2026-06-03	2027-02-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.387431	2026-06-03 18:29:59.387431	10	8	1354	\N	1
1362	500.0	2026-06-03	2027-03-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.390256	2026-06-03 18:29:59.390256	10	9	1354	\N	1
1363	500.0	2026-06-03	2027-04-08	Pix no crédito Caixa	54	8	3	f	2026-06-03 18:29:59.393159	2026-06-03 18:29:59.393159	10	10	1354	\N	1
1062	37.99	2026-05-02	2026-06-05	Ifood	12	9	2	t	2026-05-12 12:41:19.602057	2026-05-30 11:29:24.34999	1	1	\N	2026-05-30 11:29:24.3499	1
1366	500.0	2026-06-03	2026-09-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.47064	2026-06-03 18:29:59.47064	10	3	1364	\N	1
1367	500.0	2026-06-03	2026-10-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.473794	2026-06-03 18:29:59.473794	10	4	1364	\N	1
1368	500.0	2026-06-03	2026-11-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.4766	2026-06-03 18:29:59.4766	10	5	1364	\N	1
1369	500.0	2026-06-03	2026-12-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.479317	2026-06-03 18:29:59.479317	10	6	1364	\N	1
1370	500.0	2026-06-03	2027-01-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.48223	2026-06-03 18:29:59.48223	10	7	1364	\N	1
1371	500.0	2026-06-03	2027-02-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.486773	2026-06-03 18:29:59.486773	10	8	1364	\N	1
1372	500.0	2026-06-03	2027-03-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.489404	2026-06-03 18:29:59.489404	10	9	1364	\N	1
1373	500.0	2026-06-03	2027-04-07	Pix parcelado Sicoob 	54	6	3	f	2026-06-03 18:29:59.492031	2026-06-03 18:29:59.492031	10	10	1364	\N	1
1468	84.0	2026-06-13	2026-06-13	Jogo Lotofacil	24	\N	0	t	2026-06-14 21:47:54.521163	2026-06-14 21:48:02.331733	1	1	\N	2026-06-14 21:48:02.331664	1
1364	500.0	2026-06-03	2026-07-07	Pix parcelado Sicoob 	54	6	3	t	2026-06-03 18:29:59.399483	2026-06-29 19:57:59.705792	10	1	1364	2026-06-29 19:57:59.70488	1
1354	500.0	2026-06-03	2026-07-08	Pix no crédito Caixa	54	8	3	t	2026-06-03 18:29:59.299588	2026-06-29 19:58:27.067814	10	1	1354	2026-06-29 19:58:27.067751	1
1217	19.25	2026-05-26	2026-07-05	Pratiko salgados	12	7	2	t	2026-05-27 12:23:03.898213	2026-06-29 19:59:16.816007	1	1	\N	2026-06-29 19:59:16.815934	1
1218	8.0	2026-05-25	2026-07-05	Salgado MP	12	7	2	t	2026-05-27 12:23:04.022433	2026-06-29 19:59:22.215558	1	1	\N	2026-06-29 19:59:22.215486	1
1383	77.22	2026-06-04	2026-07-04	Cooktop de indução Midea	38	5	3	t	2026-06-07 17:07:34.290664	2026-07-02 00:03:40.63037	18	1	1383	2026-07-02 00:03:40.63037	1
304	17.26	2026-03-31	2026-07-04	Cafe	11	5	3	t	2026-04-21 03:44:47.362004	2026-07-02 00:03:40.63037	6	3	302	2026-07-02 00:03:40.63037	1
310	14.97	2026-03-23	2026-07-04	Psyllium	18	5	3	t	2026-04-21 03:44:47.381938	2026-07-02 00:03:40.63037	4	4	308	2026-07-02 00:03:40.63037	1
313	30.25	2026-01-09	2026-07-04	Pia	54	5	3	t	2026-04-21 03:44:47.397161	2026-07-02 00:03:40.63037	8	6	311	2026-07-02 00:03:40.63037	1
1546	83.37	2026-07-08	2027-04-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.394576	2026-07-11 12:56:47.394576	12	9	1538	\N	1
1547	83.37	2026-07-08	2027-05-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.397715	2026-07-11 12:56:47.397715	12	10	1538	\N	1
1548	83.37	2026-07-08	2027-06-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.403086	2026-07-11 12:56:47.403086	12	11	1538	\N	1
1549	83.37	2026-07-08	2027-07-08	Pix no Crédito Caixa	54	8	3	f	2026-07-11 12:56:47.406471	2026-07-11 12:56:47.406471	12	12	1538	\N	1
1355	500.0	2026-06-03	2026-08-08	Pix no crédito Caixa	54	8	3	t	2026-06-03 18:29:59.316049	2026-08-04 13:20:24.419771	10	2	1354	2026-08-04 13:20:24.419771	1
342	37.69	2026-03-30	2026-08-05	Barbeador	34	7	3	t	2026-04-21 03:44:47.534539	2026-08-04 13:20:28.742767	12	4	339	2026-08-04 13:20:28.742767	1
354	22.74	2026-03-25	2026-08-05	Grill	38	7	3	t	2026-04-21 03:44:47.561846	2026-08-04 13:20:28.742767	7	4	351	2026-08-04 13:20:28.742767	1
361	13.29	2026-03-12	2026-08-05	Potes	49	7	3	t	2026-04-21 03:44:47.580891	2026-08-04 13:20:28.742767	5	5	358	2026-08-04 13:20:28.742767	1
365	41.21	2026-01-24	2026-08-05	Torneiras e torre	54	7	3	t	2026-04-21 03:44:47.59869	2026-08-04 13:20:28.742767	13	6	362	2026-08-04 13:20:28.742767	1
395	33.86	2026-03-04	2026-08-05	Condimentos e Cafe	11	7	3	t	2026-04-21 03:46:22.215861	2026-08-04 13:20:28.742767	12	5	392	2026-08-04 13:20:28.742767	1
1365	500.0	2026-06-03	2026-08-07	Pix parcelado Sicoob 	54	6	3	t	2026-06-03 18:29:59.466605	2026-08-04 13:20:38.973086	10	2	1364	2026-08-04 13:20:38.973086	1
1595	800.0	2026-08-01	2026-08-01	Ar condicionado	54	\N	0	t	2026-08-04 13:24:50.166306	2026-08-04 13:26:42.848531	1	1	\N	2026-08-04 13:26:42.848466	1
1596	420.0	2026-08-04	2026-08-04	Caçamba	54	\N	0	t	2026-08-04 13:25:22.895631	2026-08-04 13:26:55.686852	1	1	\N	2026-08-04 13:26:55.686785	1
1621	234.98	2026-08-04	2026-08-04	Água	6	\N	0	t	2026-08-21 12:32:41.70776	2026-08-21 12:32:41.70776	1	1	\N	2026-08-21 12:32:41.707299	1
1622	24.74	2026-08-04	2026-08-04	Água	6	\N	0	t	2026-08-21 12:33:34.894823	2026-08-21 12:33:34.894823	1	1	\N	2026-08-21 12:33:34.894735	1
1623	40.54	2026-08-08	2026-08-08	Água	6	\N	0	t	2026-08-21 12:35:46.304703	2026-08-21 12:35:46.304703	1	1	\N	2026-08-21 12:35:46.304649	1
1528	100.0	2026-07-09	2026-08-05	Pix no Crédito Neon	54	12	3	t	2026-07-11 12:56:47.217491	2026-08-21 12:37:33.576004	10	1	1528	2026-08-21 12:37:33.575328	1
1066	260.0	2026-05-04	2026-06-04	Estorno Gpt	48	5	5	t	2026-05-12 22:55:36.281448	2026-06-04 13:44:52.830277	1	1	\N	2026-05-31 17:50:03.137034	1
1491	120.0	2026-09-10	2026-09-10	Internet Casa Nova	37	\N	0	f	2026-07-02 00:15:27.387224	2026-07-02 00:15:27.387224	1	1	\N	\N	1
1305	3200.0	2026-06-12	2026-06-12	Mão de Obra Azulejista 	54	\N	0	t	2026-05-30 11:22:19.228048	2026-06-14 21:08:52.759623	1	1	\N	2026-06-14 21:08:52.759547	1
1469	200.0	2026-06-06	2026-06-06	Aluguel Andaimes	54	\N	0	t	2026-06-14 21:49:49.461912	2026-06-14 21:51:03.09707	1	1	\N	2026-06-14 21:51:03.096988	1
1490	120.0	2026-08-10	2026-08-10	Internet Casa Nova	37	\N	0	t	2026-07-02 00:15:27.377981	2026-08-14 16:08:18.137984	1	1	\N	2026-08-14 16:08:18.137548	1
1492	120.0	2026-10-10	2026-10-10	Internet Casa Nova	37	\N	0	f	2026-07-02 00:15:27.394014	2026-07-02 00:15:27.394014	1	1	\N	\N	1
1470	117.89	2026-06-08	2026-07-04	Epaçadores Estorno	54	5	5	t	2026-06-14 21:50:44.017589	2026-06-27 16:33:01.29575	1	1	\N	2026-06-27 16:33:01.295665	1
1374	154.26	2026-06-02	2026-07-05	Combustível	8	7	2	t	2026-06-04 13:55:26.546845	2026-06-29 19:58:54.145863	1	1	\N	2026-06-29 19:58:54.145801	1
1375	27.09	2026-06-03	2026-07-05	Pratiko	12	7	2	t	2026-06-04 13:55:26.63539	2026-06-29 19:59:09.426478	1	1	\N	2026-06-29 19:59:09.426418	1
1493	120.0	2026-11-10	2026-11-10	Internet Casa Nova	37	\N	0	f	2026-07-02 00:15:27.444868	2026-07-02 00:15:27.444868	1	1	\N	\N	1
1494	120.0	2026-12-10	2026-12-10	Internet Casa Nova	37	\N	0	f	2026-07-02 00:15:27.452704	2026-07-02 00:15:27.452704	1	1	\N	\N	1
1495	120.0	2027-01-10	2027-01-10	Internet Casa Nova	37	\N	0	f	2026-07-02 00:15:27.458647	2026-07-02 00:15:27.458647	1	1	\N	\N	1
1182	1750.0	2026-06-01	2026-07-01	Eletrica	54	\N	0	t	2026-05-23 16:19:02.017725	2026-07-15 20:07:17.75053	1	1	\N	2026-07-15 20:07:01.915034	1
1219	5500.0	2026-05-27	2026-05-27	Eletricista 	54	\N	0	t	2026-05-27 17:11:57.984439	2026-05-27 17:11:57.984439	1	1	\N	2026-05-27 17:11:57.984224	1
1306	1250.0	2026-08-01	2026-08-01	Pintura e reforma casa antiga	54	\N	0	t	2026-05-30 11:22:19.240148	2026-08-14 16:09:22.72924	1	1	\N	2026-08-14 16:09:22.729134	1
1551	1950.0	2026-07-17	2026-07-17	Pedras restante 	54	\N	0	t	2026-07-11 13:00:03.827586	2026-07-28 18:26:49.81601	1	1	\N	2026-07-28 18:26:49.815434	1
1550	950.0	2026-07-16	2026-07-16	Mão de Obra Marmorista	54	\N	0	t	2026-07-11 12:59:30.699762	2026-07-28 18:28:01.506502	1	1	\N	2026-07-28 18:28:01.506439	1
1552	34.9	2026-06-19	2026-08-05	Store	11	7	2	t	2026-07-11 13:05:54.167645	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1553	248.23	2026-06-21	2026-08-05	Tatico	11	7	2	t	2026-07-11 13:05:54.18714	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1554	28.5	2026-06-25	2026-08-05	Ifood	12	7	2	t	2026-07-11 13:05:54.193145	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1555	13.9	2026-07-09	2026-08-05	Amazon Music	48	7	2	t	2026-07-11 13:05:54.199107	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1307	820.0	2026-08-01	2026-08-01	Mudança	54	\N	0	t	2026-05-30 11:22:19.258746	2026-08-04 13:21:49.78428	1	1	\N	2026-08-04 13:21:49.784198	1
1598	190.0	2026-08-04	2026-09-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.347171	2026-08-04 13:46:44.347171	10	1	1598	\N	1
1599	190.0	2026-08-04	2026-10-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.381032	2026-08-04 13:46:44.381032	10	2	1598	\N	1
1600	190.0	2026-08-04	2026-11-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.386524	2026-08-04 13:46:44.386524	10	3	1598	\N	1
1601	190.0	2026-08-04	2026-12-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.392532	2026-08-04 13:46:44.392532	10	4	1598	\N	1
1602	190.0	2026-08-04	2027-01-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.398252	2026-08-04 13:46:44.398252	10	5	1598	\N	1
1603	190.0	2026-08-04	2027-02-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.403468	2026-08-04 13:46:44.403468	10	6	1598	\N	1
1604	190.0	2026-08-04	2027-03-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.408983	2026-08-04 13:46:44.408983	10	7	1598	\N	1
1063	192.02	2026-05-12	2026-06-05	Combustível	8	9	2	t	2026-05-12 22:47:57.195999	2026-05-30 11:29:22.998562	1	1	\N	2026-05-30 11:29:22.998453	1
950	45.12	2026-05-07	2026-06-05	Ifood	12	9	2	t	2026-05-07 22:59:44.094707	2026-05-30 11:29:25.27629	1	1	\N	2026-05-30 11:29:25.276234	1
1065	16.09	2026-05-12	2026-06-05	Pratiko	12	9	2	t	2026-05-12 22:47:57.386502	2026-05-30 11:29:40.685733	1	1	\N	2026-05-30 11:29:40.685655	1
1064	27.79	2026-05-12	2026-06-05	Remedio Ramar	15	9	2	t	2026-05-12 22:47:57.318117	2026-05-30 11:29:44.02906	1	1	\N	2026-05-30 11:29:44.028994	1
1605	190.0	2026-08-04	2027-04-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.414191	2026-08-04 13:46:44.414191	10	8	1598	\N	1
1606	190.0	2026-08-04	2027-05-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.419498	2026-08-04 13:46:44.419498	10	9	1598	\N	1
1607	190.0	2026-08-04	2027-06-07	Pix no Crédito Sicoob	30	6	3	f	2026-08-04 13:46:44.426531	2026-08-04 13:46:44.426531	10	10	1598	\N	1
1608	100.0	2026-08-04	2026-09-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.479638	2026-08-04 13:46:44.479638	10	1	1608	\N	1
1609	100.0	2026-08-04	2026-10-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.496099	2026-08-04 13:46:44.496099	10	2	1608	\N	1
1610	100.0	2026-08-04	2026-11-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.504811	2026-08-04 13:46:44.504811	10	3	1608	\N	1
1611	100.0	2026-08-04	2026-12-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.511664	2026-08-04 13:46:44.511664	10	4	1608	\N	1
1612	100.0	2026-08-04	2027-01-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.578057	2026-08-04 13:46:44.578057	10	5	1608	\N	1
1613	100.0	2026-08-04	2027-02-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.58486	2026-08-04 13:46:44.58486	10	6	1608	\N	1
952	117.5	2026-05-08	2026-06-05	Novo quadro de energia	54	9	3	t	2026-05-08 20:50:28.259262	2026-05-30 11:29:32.322616	2	1	952	2026-05-30 11:29:32.322537	1
1068	44.97	2026-05-14	2026-06-05	Store	11	9	2	t	2026-05-15 11:32:14.501193	2026-05-30 11:29:53.494783	1	1	\N	2026-05-30 11:29:53.494726	1
1069	31.98	2026-05-14	2026-06-05	Store	11	9	2	t	2026-05-15 11:32:14.508098	2026-05-30 11:29:55.119654	1	1	\N	2026-05-30 11:29:55.11959	1
1067	44.97	2026-05-14	2026-06-05	Store	11	9	2	t	2026-05-15 11:32:14.447266	2026-05-30 11:29:56.838656	1	1	\N	2026-05-30 11:29:56.838576	1
1070	216.08	2026-05-14	2026-06-05	Store	11	9	2	t	2026-05-15 11:32:14.580018	2026-05-30 11:29:57.416618	1	1	\N	2026-05-30 11:29:57.416546	1
951	54.26	2026-05-08	2026-06-05	Supermercado Store	11	9	2	t	2026-05-08 20:50:28.138468	2026-05-30 11:29:58.030406	1	1	\N	2026-05-30 11:29:58.030339	1
1310	2000.0	2026-06-01	2026-06-01	Forro Janio 2	54	\N	0	t	2026-05-30 11:32:29.440784	2026-06-07 18:35:31.338407	1	1	\N	2026-06-07 18:35:31.338083	1
1220	250.0	2026-05-28	2026-07-05	Pix no crédito	54	6	3	t	2026-05-29 10:59:30.379113	2026-06-29 19:58:06.351605	12	1	1220	2026-06-29 19:58:06.351534	1
1572	33.31	2026-07-21	2026-09-05	Tranqueira na Amazon	2	7	3	f	2026-07-28 18:15:09.281625	2026-07-28 18:15:09.281625	8	2	1571	\N	1
1614	100.0	2026-08-04	2027-03-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.59308	2026-08-04 13:46:44.59308	10	7	1608	\N	1
1222	250.0	2026-05-28	2026-09-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.49068	2026-05-31 23:57:25.493291	12	3	1220	\N	1
1223	250.0	2026-05-28	2026-10-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.49722	2026-05-31 23:57:25.49778	12	4	1220	\N	1
1224	250.0	2026-05-28	2026-11-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.501322	2026-05-31 23:57:25.502348	12	5	1220	\N	1
1225	250.0	2026-05-28	2026-12-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.565263	2026-05-31 23:57:25.576605	12	6	1220	\N	1
1573	33.31	2026-07-21	2026-10-05	Tranqueira na Amazon	2	7	3	f	2026-07-28 18:15:09.289274	2026-07-28 18:15:09.289274	8	3	1571	\N	1
1376	40.64	2026-06-05	2026-07-05	Capa de volante Shopee	10	9	2	t	2026-06-05 13:01:45.204821	2026-07-02 00:03:43.876536	1	1	\N	2026-07-02 00:03:43.876536	1
1226	250.0	2026-05-28	2027-01-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.571729	2026-05-31 23:57:25.580226	12	7	1220	\N	1
1227	250.0	2026-05-28	2027-02-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.581507	2026-05-31 23:57:25.58363	12	8	1220	\N	1
953	117.5	2026-05-08	2026-07-05	Novo quadro de energia	54	9	3	t	2026-05-08 20:50:28.343705	2026-07-02 00:03:43.876536	2	2	952	2026-07-02 00:03:43.876536	1
1574	33.31	2026-07-21	2026-11-05	Tranqueira na Amazon	2	7	3	f	2026-07-28 18:15:09.296276	2026-07-28 18:15:09.296276	8	4	1571	\N	1
1496	53.9	2026-06-25	2026-07-04	YouTube Premium	48	5	2	t	2026-07-02 00:34:00.651474	2026-07-02 00:34:00.651474	1	1	\N	2026-07-02 00:34:00.651393	1
1497	158.8	2026-06-09	2026-07-04	Meli Plus	48	5	2	t	2026-07-02 00:34:00.670109	2026-07-02 00:34:00.670109	1	1	\N	2026-07-02 00:34:00.670082	1
1228	250.0	2026-05-28	2027-03-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.666716	2026-05-31 23:57:25.588119	12	9	1220	\N	1
1229	250.0	2026-05-28	2027-04-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.67085	2026-05-31 23:57:25.596126	12	10	1220	\N	1
1230	250.0	2026-05-28	2027-05-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.674327	2026-05-31 23:57:25.602888	12	11	1220	\N	1
1231	250.0	2026-05-28	2027-06-05	Pix no crédito	54	6	3	f	2026-05-29 10:59:30.677699	2026-05-31 23:57:25.679122	12	12	1220	\N	1
1232	2500.0	2026-05-28	2026-05-28	Forro Janio 1	54	\N	0	t	2026-05-29 10:59:30.764624	2026-06-01 13:58:23.737518	1	1	\N	2026-06-01 13:58:23.737213	1
1498	19.91	2026-06-07	2026-07-04	Crunchroll	48	5	2	t	2026-07-02 00:34:55.97464	2026-07-02 00:34:55.97464	1	1	\N	2026-07-02 00:34:55.974609	1
1499	12.0	2026-06-21	2026-07-04	Paramoun	48	5	2	t	2026-07-02 00:35:52.873338	2026-07-02 00:35:52.873338	1	1	\N	2026-07-02 00:35:52.873309	1
300	28.84	2026-04-12	2026-11-04	Bota	31	5	3	f	2026-04-21 03:44:47.335665	2026-07-02 00:39:51.773203	8	7	294	\N	1
301	28.84	2026-04-12	2026-12-04	Bota	31	5	3	f	2026-04-21 03:44:47.337179	2026-07-02 00:39:51.776712	8	8	294	\N	1
1471	423.03	2026-06-16	2026-07-01	Energia	5	\N	0	t	2026-06-16 18:06:15.889074	2026-07-07 23:50:08.639821	1	1	\N	2026-07-07 23:50:08.638543	1
1575	33.31	2026-07-21	2026-12-05	Tranqueira na Amazon	2	7	3	f	2026-07-28 18:15:09.365088	2026-07-28 18:15:09.365088	8	5	1571	\N	1
1576	33.31	2026-07-21	2027-01-05	Tranqueira na Amazon	2	7	3	f	2026-07-28 18:15:09.370702	2026-07-28 18:15:09.370702	8	6	1571	\N	1
1577	33.31	2026-07-21	2027-02-05	Tranqueira na Amazon	2	7	3	f	2026-07-28 18:15:09.375804	2026-07-28 18:15:09.375804	8	7	1571	\N	1
1578	33.31	2026-07-21	2027-03-05	Tranqueira na Amazon	2	7	3	f	2026-07-28 18:15:09.382984	2026-07-28 18:15:09.382984	8	8	1571	\N	1
1571	33.31	2026-07-21	2026-08-05	Tranqueira na Amazon	2	7	3	t	2026-07-28 18:15:09.072805	2026-08-04 13:20:28.742767	8	1	1571	2026-08-04 13:20:28.742767	1
1579	20.0	2026-07-18	2026-08-05	Coisas no parque	12	7	2	t	2026-07-28 18:15:09.465035	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1580	25.96	2026-07-17	2026-08-05	Store	11	7	2	t	2026-07-28 18:15:09.485133	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1556	59.4	2026-07-02	2026-08-05	Lampadas	54	9	2	t	2026-07-11 13:10:22.717807	2026-08-04 13:20:36.282873	1	1	\N	2026-08-04 13:20:36.282873	1
1557	232.19	2026-07-02	2026-08-05	Store	11	9	2	t	2026-07-11 13:10:22.733681	2026-08-04 13:20:36.282873	1	1	\N	2026-08-04 13:20:36.282873	1
1558	99.9	2026-07-03	2026-08-05	GPT	48	9	2	t	2026-07-11 13:10:22.740983	2026-08-04 13:20:36.282873	1	1	\N	2026-08-04 13:20:36.282873	1
1559	264.32	2026-07-04	2026-08-05	Combustivel	8	9	2	t	2026-07-11 13:10:22.747669	2026-08-04 13:20:36.282873	1	1	\N	2026-08-04 13:20:36.282873	1
1560	109.98	2026-07-08	2026-08-05	Remedios	15	9	2	t	2026-07-11 13:10:22.753467	2026-08-04 13:20:36.282873	1	1	\N	2026-08-04 13:20:36.282873	1
1561	30.96	2026-07-08	2026-08-05	Remedios	15	9	2	t	2026-07-11 13:10:22.759417	2026-08-04 13:20:36.282873	1	1	\N	2026-08-04 13:20:36.282873	1
1562	20.38	2026-07-09	2026-08-05	Pratiko	12	9	2	t	2026-07-11 13:10:22.765357	2026-08-04 13:20:36.282873	1	1	\N	2026-08-04 13:20:36.282873	1
1221	250.0	2026-05-28	2026-08-05	Pix no crédito	54	6	3	t	2026-05-29 10:59:30.486778	2026-08-04 13:20:38.973086	12	2	1220	2026-08-04 13:20:38.973086	1
1582	18.97	2026-07-08	2026-08-07	Pratiko	11	6	2	t	2026-07-28 18:25:56.705937	2026-08-04 13:20:38.973086	1	1	\N	2026-08-04 13:20:38.973086	1
1583	6.95	2026-07-06	2026-08-07	Poly san	54	6	2	t	2026-07-28 18:25:56.726711	2026-08-04 13:20:38.973086	1	1	\N	2026-08-04 13:20:38.973086	1
1584	2.0	2026-07-06	2026-08-07	Poly san	54	6	2	t	2026-07-28 18:25:56.769735	2026-08-04 13:20:38.973086	1	1	\N	2026-08-04 13:20:38.973086	1
1585	37.96	2026-07-03	2026-08-07	Nobre Frios	12	6	2	t	2026-07-28 18:25:56.779312	2026-08-04 13:20:38.973086	1	1	\N	2026-08-04 13:20:38.973086	1
1586	12.65	2026-07-02	2026-08-07	Pratiko	11	6	2	t	2026-07-28 18:25:56.789219	2026-08-04 13:20:38.973086	1	1	\N	2026-08-04 13:20:38.973086	1
1615	100.0	2026-08-04	2027-04-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.598711	2026-08-04 13:46:44.598711	10	8	1608	\N	1
1616	100.0	2026-08-04	2027-05-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.605462	2026-08-04 13:46:44.605462	10	9	1608	\N	1
1617	100.0	2026-08-04	2027-06-08	Pix no Crédito Caixa	30	8	3	f	2026-08-04 13:46:44.61096	2026-08-04 13:46:44.61096	10	10	1608	\N	1
957	216.0	2026-08-08	2026-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.360097	2026-05-08 22:11:54.360097	1	1	\N	\N	1
958	216.0	2026-09-08	2026-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.371084	2026-05-08 22:11:54.371084	1	1	\N	\N	1
959	216.0	2026-10-08	2026-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.449174	2026-05-08 22:11:54.449174	1	1	\N	\N	1
960	216.0	2026-11-08	2026-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.457222	2026-05-08 22:11:54.457222	1	1	\N	\N	1
961	216.0	2026-12-08	2027-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.506293	2026-05-08 22:11:54.506293	1	1	\N	\N	1
962	216.0	2027-01-08	2027-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.554672	2026-05-08 22:11:54.554672	1	1	\N	\N	1
963	216.0	2027-02-08	2027-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.563209	2026-05-08 22:11:54.563209	1	1	\N	\N	1
964	216.0	2027-03-08	2027-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.570472	2026-05-08 22:11:54.570472	1	1	\N	\N	1
965	216.0	2027-04-08	2027-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.577357	2026-05-08 22:11:54.577357	1	1	\N	\N	1
966	216.0	2027-05-08	2027-06-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.652502	2026-05-08 22:11:54.652502	1	1	\N	\N	1
967	216.0	2027-06-08	2027-07-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.749782	2026-05-08 22:11:54.749782	1	1	\N	\N	1
968	216.0	2027-07-08	2027-08-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.761437	2026-05-08 22:11:54.761437	1	1	\N	\N	1
969	216.0	2027-08-08	2027-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.768374	2026-05-08 22:11:54.768374	1	1	\N	\N	1
970	216.0	2027-09-08	2027-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.847948	2026-05-08 22:11:54.847948	1	1	\N	\N	1
971	216.0	2027-10-08	2027-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.854701	2026-05-08 22:11:54.854701	1	1	\N	\N	1
972	216.0	2027-11-08	2027-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.863631	2026-05-08 22:11:54.863631	1	1	\N	\N	1
973	216.0	2027-12-08	2028-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.871607	2026-05-08 22:11:54.871607	1	1	\N	\N	1
974	216.0	2028-01-08	2028-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.877936	2026-05-08 22:11:54.877936	1	1	\N	\N	1
975	216.0	2028-02-08	2028-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.883977	2026-05-08 22:11:54.883977	1	1	\N	\N	1
976	216.0	2028-03-08	2028-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.951224	2026-05-08 22:11:54.951224	1	1	\N	\N	1
977	216.0	2028-04-08	2028-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.956887	2026-05-08 22:11:54.956887	1	1	\N	\N	1
978	216.0	2028-05-08	2028-06-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.962091	2026-05-08 22:11:54.962091	1	1	\N	\N	1
979	216.0	2028-06-08	2028-07-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.967224	2026-05-08 22:11:54.967224	1	1	\N	\N	1
980	216.0	2028-07-08	2028-08-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.973578	2026-05-08 22:11:54.973578	1	1	\N	\N	1
981	216.0	2028-08-08	2028-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.981349	2026-05-08 22:11:54.981349	1	1	\N	\N	1
982	216.0	2028-09-08	2028-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:54.987637	2026-05-08 22:11:54.987637	1	1	\N	\N	1
983	216.0	2028-10-08	2028-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.051104	2026-05-08 22:11:55.051104	1	1	\N	\N	1
984	216.0	2028-11-08	2028-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.058802	2026-05-08 22:11:55.058802	1	1	\N	\N	1
985	216.0	2028-12-08	2029-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.069528	2026-05-08 22:11:55.069528	1	1	\N	\N	1
986	216.0	2029-01-08	2029-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.075305	2026-05-08 22:11:55.075305	1	1	\N	\N	1
987	216.0	2029-02-08	2029-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.151052	2026-05-08 22:11:55.151052	1	1	\N	\N	1
988	216.0	2029-03-08	2029-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.156416	2026-05-08 22:11:55.156416	1	1	\N	\N	1
989	216.0	2029-04-08	2029-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.16162	2026-05-08 22:11:55.16162	1	1	\N	\N	1
990	216.0	2029-05-08	2029-06-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.167064	2026-05-08 22:11:55.167064	1	1	\N	\N	1
991	216.0	2029-06-08	2029-07-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.173359	2026-05-08 22:11:55.173359	1	1	\N	\N	1
992	216.0	2029-07-08	2029-08-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.178456	2026-05-08 22:11:55.178456	1	1	\N	\N	1
993	216.0	2029-08-08	2029-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.248335	2026-05-08 22:11:55.248335	1	1	\N	\N	1
994	216.0	2029-09-08	2029-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.256477	2026-05-08 22:11:55.256477	1	1	\N	\N	1
995	216.0	2029-10-08	2029-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.262562	2026-05-08 22:11:55.262562	1	1	\N	\N	1
996	216.0	2029-11-08	2029-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.268366	2026-05-08 22:11:55.268366	1	1	\N	\N	1
997	216.0	2029-12-08	2030-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.27386	2026-05-08 22:11:55.27386	1	1	\N	\N	1
998	216.0	2030-01-08	2030-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.279468	2026-05-08 22:11:55.279468	1	1	\N	\N	1
999	216.0	2030-02-08	2030-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.286109	2026-05-08 22:11:55.286109	1	1	\N	\N	1
1000	216.0	2030-03-08	2030-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.352249	2026-05-08 22:11:55.352249	1	1	\N	\N	1
1001	216.0	2030-04-08	2030-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.359065	2026-05-08 22:11:55.359065	1	1	\N	\N	1
1002	216.0	2030-05-08	2030-06-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.364504	2026-05-08 22:11:55.364504	1	1	\N	\N	1
1003	216.0	2030-06-08	2030-07-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.370136	2026-05-08 22:11:55.370136	1	1	\N	\N	1
1004	216.0	2030-07-08	2030-08-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.377652	2026-05-08 22:11:55.377652	1	1	\N	\N	1
1005	216.0	2030-08-08	2030-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.38345	2026-05-08 22:11:55.38345	1	1	\N	\N	1
1006	216.0	2030-09-08	2030-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.447697	2026-05-08 22:11:55.447697	1	1	\N	\N	1
1007	216.0	2030-10-08	2030-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.456147	2026-05-08 22:11:55.456147	1	1	\N	\N	1
1008	216.0	2030-11-08	2030-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.462275	2026-05-08 22:11:55.462275	1	1	\N	\N	1
1009	216.0	2030-12-08	2031-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.468383	2026-05-08 22:11:55.468383	1	1	\N	\N	1
1010	216.0	2031-01-08	2031-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.473672	2026-05-08 22:11:55.473672	1	1	\N	\N	1
1011	216.0	2031-02-08	2031-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.478963	2026-05-08 22:11:55.478963	1	1	\N	\N	1
1012	216.0	2031-03-08	2031-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.485199	2026-05-08 22:11:55.485199	1	1	\N	\N	1
1013	216.0	2031-04-08	2031-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.491969	2026-05-08 22:11:55.491969	1	1	\N	\N	1
1014	216.0	2031-05-08	2031-06-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.559844	2026-05-08 22:11:55.559844	1	1	\N	\N	1
955	216.0	2026-06-08	2026-07-01	Consignado Alfa 2	30	\N	1	t	2026-05-08 22:11:54.276259	2026-06-29 20:05:48.561012	1	1	\N	2026-06-29 20:05:48.560948	1
956	216.0	2026-07-08	2026-08-01	Consignado Alfa 2	30	\N	1	t	2026-05-08 22:11:54.353078	2026-08-04 13:26:39.099532	1	1	\N	2026-08-04 13:26:39.099452	1
1015	216.0	2031-06-08	2031-07-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.565455	2026-05-08 22:11:55.565455	1	1	\N	\N	1
1016	216.0	2031-07-08	2031-08-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.571487	2026-05-08 22:11:55.571487	1	1	\N	\N	1
1017	216.0	2031-08-08	2031-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.576584	2026-05-08 22:11:55.576584	1	1	\N	\N	1
1018	216.0	2031-09-08	2031-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.650898	2026-05-08 22:11:55.650898	1	1	\N	\N	1
1019	216.0	2031-10-08	2031-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.657168	2026-05-08 22:11:55.657168	1	1	\N	\N	1
1020	216.0	2031-11-08	2031-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.662639	2026-05-08 22:11:55.662639	1	1	\N	\N	1
1021	216.0	2031-12-08	2032-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.668164	2026-05-08 22:11:55.668164	1	1	\N	\N	1
1022	216.0	2032-01-08	2032-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.673538	2026-05-08 22:11:55.673538	1	1	\N	\N	1
1023	216.0	2032-02-08	2032-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.681207	2026-05-08 22:11:55.681207	1	1	\N	\N	1
1024	216.0	2032-03-08	2032-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.686923	2026-05-08 22:11:55.686923	1	1	\N	\N	1
1025	216.0	2032-04-08	2032-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.692247	2026-05-08 22:11:55.692247	1	1	\N	\N	1
1026	216.0	2032-05-08	2032-06-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.697586	2026-05-08 22:11:55.697586	1	1	\N	\N	1
1027	216.0	2032-06-08	2032-07-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.750857	2026-05-08 22:11:55.750857	1	1	\N	\N	1
1028	216.0	2032-07-08	2032-08-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.756299	2026-05-08 22:11:55.756299	1	1	\N	\N	1
1029	216.0	2032-08-08	2032-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.761204	2026-05-08 22:11:55.761204	1	1	\N	\N	1
1030	216.0	2032-09-08	2032-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.766091	2026-05-08 22:11:55.766091	1	1	\N	\N	1
1031	216.0	2032-10-08	2032-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.770845	2026-05-08 22:11:55.770845	1	1	\N	\N	1
1032	216.0	2032-11-08	2032-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.77552	2026-05-08 22:11:55.77552	1	1	\N	\N	1
1033	216.0	2032-12-08	2033-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.780632	2026-05-08 22:11:55.780632	1	1	\N	\N	1
1034	216.0	2033-01-08	2033-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.785747	2026-05-08 22:11:55.785747	1	1	\N	\N	1
1035	216.0	2033-02-08	2033-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.790803	2026-05-08 22:11:55.790803	1	1	\N	\N	1
1036	216.0	2033-03-08	2033-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.795796	2026-05-08 22:11:55.795796	1	1	\N	\N	1
1037	216.0	2033-04-08	2033-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.800842	2026-05-08 22:11:55.800842	1	1	\N	\N	1
1038	216.0	2033-05-08	2033-06-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.805934	2026-05-08 22:11:55.805934	1	1	\N	\N	1
1039	216.0	2033-06-08	2033-07-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.850932	2026-05-08 22:11:55.850932	1	1	\N	\N	1
1040	216.0	2033-07-08	2033-08-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.856686	2026-05-08 22:11:55.856686	1	1	\N	\N	1
1041	216.0	2033-08-08	2033-09-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.862414	2026-05-08 22:11:55.862414	1	1	\N	\N	1
1042	216.0	2033-09-08	2033-10-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.867616	2026-05-08 22:11:55.867616	1	1	\N	\N	1
1043	216.0	2033-10-08	2033-11-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.87249	2026-05-08 22:11:55.87249	1	1	\N	\N	1
1044	216.0	2033-11-08	2033-12-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.8784	2026-05-08 22:11:55.8784	1	1	\N	\N	1
1045	216.0	2033-12-08	2034-01-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.883422	2026-05-08 22:11:55.883422	1	1	\N	\N	1
1046	216.0	2034-01-08	2034-02-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.888611	2026-05-08 22:11:55.888611	1	1	\N	\N	1
1047	216.0	2034-02-08	2034-03-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.893801	2026-05-08 22:11:55.893801	1	1	\N	\N	1
1048	216.0	2034-03-08	2034-04-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.898886	2026-05-08 22:11:55.898886	1	1	\N	\N	1
1049	216.0	2034-04-08	2034-05-01	Consignado Alfa 2	30	\N	1	f	2026-05-08 22:11:55.90392	2026-05-08 22:11:55.90392	1	1	\N	\N	1
1071	313.32	2026-05-19	2026-06-05	Celular Novo	38	9	3	t	2026-05-20 17:09:39.57362	2026-05-30 11:29:21.353897	12	1	1071	2026-05-30 11:29:21.353175	1
1083	26.65	2026-05-17	2026-06-05	Pastel 99	12	9	2	t	2026-05-20 17:09:39.887731	2026-05-30 11:29:33.469928	1	1	\N	2026-05-30 11:29:33.469856	1
1084	41.4	2026-05-16	2026-06-05	Sorvete	12	9	2	t	2026-05-20 17:09:39.902149	2026-05-30 11:29:51.329339	1	1	\N	2026-05-30 11:29:51.329272	1
1311	53.9	2026-05-25	2026-06-08	YouTube Premium	48	5	2	t	2026-05-31 17:47:24.984727	2026-06-04 13:49:08.638546	1	1	\N	2026-05-31 17:50:10.405487	1
1186	10.98	2026-05-22	2026-06-08	Pizza 99	12	8	2	t	2026-05-24 11:39:36.20057	2026-06-02 16:47:11.994467	1	1	\N	2026-06-02 16:47:11.994467	1
1072	313.28	2026-05-19	2026-07-05	Celular Novo	38	9	3	t	2026-05-20 17:09:39.694899	2026-07-02 00:03:43.876536	12	2	1071	2026-07-02 00:03:43.876536	1
1073	313.28	2026-05-19	2026-08-05	Celular Novo	38	9	3	t	2026-05-20 17:09:39.701157	2026-08-04 13:20:36.282873	12	3	1071	2026-08-04 13:20:36.282873	1
1051	47.55	2026-05-03	2026-06-05	Remédios	15	9	3	t	2026-05-09 11:46:35.524299	2026-05-30 11:29:49.213426	3	1	1051	2026-05-30 11:29:49.213366	1
1050	285.63	2026-05-06	2026-06-05	Supermercado Tatico	11	9	2	t	2026-05-09 11:46:35.408684	2026-05-30 11:29:59.786372	1	1	\N	2026-05-30 11:29:59.786307	1
1054	19.9	2026-05-07	2026-06-04	Crunchyroll 	48	5	2	t	2026-05-09 11:48:12.10815	2026-06-04 13:49:15.957097	1	1	\N	2026-05-31 17:50:07.340537	1
1314	42.57	2026-05-31	2026-09-04	Torneira	54	5	3	f	2026-05-31 17:56:08.605357	2026-05-31 17:56:08.605357	10	3	1312	\N	1
1385	77.22	2026-06-04	2026-09-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.368689	2026-06-07 17:07:34.368689	18	3	1383	\N	1
1386	77.22	2026-06-04	2026-10-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.376664	2026-06-07 17:07:34.376664	18	4	1383	\N	1
1387	77.22	2026-06-04	2026-11-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.38189	2026-06-07 17:07:34.38189	18	5	1383	\N	1
1388	77.22	2026-06-04	2026-12-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.386668	2026-06-07 17:07:34.386668	18	6	1383	\N	1
1389	77.22	2026-06-04	2027-01-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.391461	2026-06-07 17:07:34.391461	18	7	1383	\N	1
1315	42.57	2026-05-31	2026-10-04	Torneira	54	5	3	f	2026-05-31 17:56:08.611544	2026-05-31 17:56:08.611544	10	4	1312	\N	1
1316	42.57	2026-05-31	2026-11-04	Torneira	54	5	3	f	2026-05-31 17:56:08.661552	2026-05-31 17:56:08.661552	10	5	1312	\N	1
1317	42.57	2026-05-31	2026-12-04	Torneira	54	5	3	f	2026-05-31 17:56:08.666197	2026-05-31 17:56:08.666197	10	6	1312	\N	1
1318	42.57	2026-05-31	2027-01-04	Torneira	54	5	3	f	2026-05-31 17:56:08.670852	2026-05-31 17:56:08.670852	10	7	1312	\N	1
1319	42.57	2026-05-31	2027-02-04	Torneira	54	5	3	f	2026-05-31 17:56:08.676709	2026-05-31 17:56:08.676709	10	8	1312	\N	1
1320	42.57	2026-05-31	2027-03-04	Torneira	54	5	3	f	2026-05-31 17:56:08.679929	2026-05-31 17:56:08.679929	10	9	1312	\N	1
1321	42.57	2026-05-31	2027-04-04	Torneira	54	5	3	f	2026-05-31 17:56:08.683476	2026-05-31 17:56:08.683476	10	10	1312	\N	1
1085	48.47	2026-05-21	2026-06-08	Pastel 99	12	8	2	t	2026-05-22 12:34:29.716772	2026-06-02 16:47:11.994467	1	1	\N	2026-06-02 16:47:11.994467	1
1390	77.22	2026-06-04	2027-02-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.396866	2026-06-07 17:07:34.396866	18	8	1383	\N	1
1391	77.22	2026-06-04	2027-03-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.401842	2026-06-07 17:07:34.401842	18	9	1383	\N	1
1392	77.22	2026-06-04	2027-04-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.470617	2026-06-07 17:07:34.470617	18	10	1383	\N	1
1393	77.22	2026-06-04	2027-05-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.475544	2026-06-07 17:07:34.475544	18	11	1383	\N	1
1394	77.22	2026-06-04	2027-06-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.480535	2026-06-07 17:07:34.480535	18	12	1383	\N	1
1395	77.22	2026-06-04	2027-07-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.484822	2026-06-07 17:07:34.484822	18	13	1383	\N	1
1396	77.22	2026-06-04	2027-08-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.489437	2026-06-07 17:07:34.489437	18	14	1383	\N	1
1397	77.22	2026-06-04	2027-09-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.494072	2026-06-07 17:07:34.494072	18	15	1383	\N	1
1398	77.22	2026-06-04	2027-10-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.498531	2026-06-07 17:07:34.498531	18	16	1383	\N	1
1399	77.22	2026-06-04	2027-11-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.502923	2026-06-07 17:07:34.502923	18	17	1383	\N	1
1400	77.22	2026-06-04	2027-12-04	Cooktop de indução Midea	38	5	3	f	2026-06-07 17:07:34.507707	2026-06-07 17:07:34.507707	18	18	1383	\N	1
1402	47.92	2026-06-06	2026-07-08	Pastel 99	12	8	2	t	2026-06-07 17:12:16.782616	2026-06-29 19:58:34.026679	1	1	\N	2026-06-29 19:58:34.026591	1
1401	37.85	2026-05-30	2026-07-08	Pastel 99	12	8	2	t	2026-06-07 17:12:16.72096	2026-06-29 19:58:36.708411	1	1	\N	2026-06-29 19:58:36.708355	1
1403	10.98	2026-06-05	2026-07-08	Pizza 99	12	8	2	t	2026-06-07 17:12:16.791868	2026-06-29 19:58:41.356326	1	1	\N	2026-06-29 19:58:41.356221	1
1384	77.22	2026-06-04	2026-08-04	Cooktop de indução Midea	38	5	3	t	2026-06-07 17:07:34.30679	2026-08-04 13:20:32.113738	18	2	1383	2026-08-04 13:20:32.113738	1
1312	42.57	2026-05-31	2026-07-04	Torneira	54	5	3	t	2026-05-31 17:56:08.563937	2026-07-02 00:03:40.63037	10	1	1312	2026-07-02 00:03:40.63037	1
1052	47.55	2026-05-03	2026-07-05	Remédios	15	9	3	t	2026-05-09 11:46:35.593772	2026-07-02 00:03:43.876536	3	2	1051	2026-07-02 00:03:43.876536	1
1313	42.57	2026-05-31	2026-08-04	Torneira	54	5	3	t	2026-05-31 17:56:08.600309	2026-08-04 13:20:32.113738	10	2	1312	2026-08-04 13:20:32.113738	1
1506	117.9	2026-06-03	2026-07-04	Espaçadores e Cunhas	54	5	2	t	2026-07-02 00:42:28.27336	2026-07-02 00:42:28.27336	1	1	\N	2026-07-02 00:42:28.273059	1
1053	47.55	2026-05-03	2026-08-05	Remédios	15	9	3	t	2026-05-09 11:46:35.598356	2026-08-04 13:20:36.282873	3	3	1051	2026-08-04 13:20:36.282873	1
1563	54.25	2026-07-11	2026-08-05	Remedios	15	9	3	t	2026-07-11 17:08:44.939745	2026-08-04 13:20:36.282873	3	1	1563	2026-08-04 13:20:36.282873	1
1587	950.0	2026-08-04	2026-08-04	Mão de Obra Marmorista 2	54	\N	0	t	2026-07-28 18:27:52.081863	2026-08-14 16:08:43.981464	1	1	\N	2026-08-14 16:08:43.978161	1
1618	152.44	2026-07-23	2026-08-13	Store	11	11	2	t	2026-08-04 13:49:37.310299	2026-08-21 12:38:28.362925	1	1	\N	2026-08-21 12:38:28.362925	1
1086	29.09	2026-05-01	2026-06-05	Amazon Cafe	11	7	2	t	2026-05-22 14:44:58.874574	2026-05-29 11:11:20.656579	1	1	\N	2026-05-29 11:11:20.656499	1
1093	269.1	2026-05-04	2026-06-04	GPT plus	48	5	2	t	2026-05-22 14:48:57.933908	2026-06-04 13:44:42.106419	1	1	\N	2026-05-31 17:50:05.53396	1
1094	66.16	2026-05-05	2026-06-04	GPT plus	48	5	5	t	2026-05-22 14:48:57.976639	2026-06-04 13:44:49.659988	1	1	\N	2026-05-31 17:50:06.393697	1
1090	11.9	2026-05-09	2026-06-05	AMAZON MUSIC	48	7	2	t	2026-05-22 14:44:59.081003	2026-06-04 13:47:45.573667	1	1	\N	2026-05-29 11:11:26.286349	1
1087	162.55	2026-05-04	2026-06-05	Rede Store	11	7	2	t	2026-05-22 14:44:58.967591	2026-05-29 11:11:21.712482	1	1	\N	2026-05-29 11:11:21.712411	1
1404	3050.0	2026-06-27	2026-06-27	Forro Janio 3	54	\N	0	t	2026-06-07 18:35:24.67017	2026-06-27 16:33:16.894926	1	1	\N	2026-06-27 16:33:16.893878	1
1088	23.97	2026-05-04	2026-06-05	Nobre Frios	11	7	2	t	2026-05-22 14:44:58.981308	2026-05-29 11:11:24.988736	1	1	\N	2026-05-29 11:11:24.988654	1
1092	231.9	2026-05-21	2026-07-05	Combustível	8	7	2	t	2026-05-22 14:44:59.167269	2026-06-29 19:58:48.67111	1	1	\N	2026-06-29 19:58:48.67105	1
1089	70.0	2026-05-05	2026-06-05	Academia	18	7	2	t	2026-05-22 14:44:59.07115	2026-05-29 11:11:25.59972	1	1	\N	2026-05-29 11:11:25.599652	1
1091	56.0	2026-05-19	2026-06-05	Empadinha	12	7	2	t	2026-05-22 14:44:59.089155	2026-05-29 11:11:28.000609	1	1	\N	2026-05-29 11:11:28.000545	1
1055	49.78	2026-05-10	2026-06-05	Ifood	12	9	2	t	2026-05-10 23:29:03.399005	2026-05-30 11:29:26.145442	1	1	\N	2026-05-30 11:29:26.14529	1
1507	7.95	2026-05-30	2026-07-05	Ifood	48	9	2	t	2026-07-02 00:44:14.83397	2026-07-02 00:44:14.83397	1	1	\N	2026-07-02 00:44:14.833938	1
1322	3.2	2026-05-07	2026-06-07	Proteção perda ou Roubo	28	6	2	t	2026-06-01 00:10:18.929337	2026-06-01 00:10:45.034781	1	1	\N	2026-06-01 00:10:45.034705	1
1508	3.2	2026-06-07	2026-07-07	Proteção perda ou Roubo	28	6	2	t	2026-07-02 00:45:53.345036	2026-07-02 00:45:53.345036	1	1	\N	2026-07-02 00:45:53.345007	1
1510	3.2	2026-08-07	2026-09-07	Proteção perda ou Roubo	28	6	2	f	2026-07-02 00:45:53.360792	2026-07-02 00:45:53.360792	1	1	\N	\N	1
1511	3.2	2026-09-07	2026-10-07	Proteção perda ou Roubo	28	6	2	f	2026-07-02 00:45:53.36668	2026-07-02 00:45:53.36668	1	1	\N	\N	1
1512	3.2	2026-10-07	2026-11-07	Proteção perda ou Roubo	28	6	2	f	2026-07-02 00:45:53.372522	2026-07-02 00:45:53.372522	1	1	\N	\N	1
1513	3.2	2026-11-07	2026-12-07	Proteção perda ou Roubo	28	6	2	f	2026-07-02 00:45:53.378038	2026-07-02 00:45:53.378038	1	1	\N	\N	1
1588	30.06	2026-08-02	2026-08-02	Energia	5	\N	0	t	2026-08-04 13:02:29.511074	2026-08-04 13:02:29.511074	1	1	\N	2026-08-04 13:02:29.510949	1
1589	113.75	2026-07-04	2026-07-04	Água	6	\N	0	t	2026-08-04 13:07:59.19265	2026-08-04 13:07:59.19265	1	1	\N	2026-08-04 13:07:59.192585	1
1590	121.23	2026-08-04	2026-08-04	Água	6	\N	0	t	2026-08-04 13:07:59.213708	2026-08-04 13:07:59.213708	1	1	\N	2026-08-04 13:07:59.213652	1
1566	242.39	2026-07-15	2026-08-05	Tatico	11	7	2	t	2026-07-15 20:08:50.127807	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1567	35.0	2026-07-15	2026-08-05	Alho	11	7	2	t	2026-07-15 20:08:50.233408	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1568	47.45	2026-07-12	2026-08-05	Store	11	7	2	t	2026-07-15 20:11:33.619216	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1569	140.0	2026-07-13	2026-08-05	Academia	18	7	2	t	2026-07-15 20:11:33.633048	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1570	16.97	2026-07-13	2026-08-05	Store	11	7	2	t	2026-07-15 20:11:33.639588	2026-08-04 13:20:28.742767	1	1	\N	2026-08-04 13:20:28.742767	1
1509	3.2	2026-07-07	2026-08-07	Proteção perda ou Roubo	28	6	2	t	2026-07-02 00:45:53.352607	2026-08-04 13:20:38.973086	1	1	\N	2026-08-04 13:20:38.973086	1
1473	3500.0	2026-07-31	2026-08-01	Forro Janio 4 	54	\N	0	t	2026-06-19 17:36:29.265578	2026-08-04 13:21:20.330311	1	1	\N	2026-08-04 13:21:20.330156	1
1619	1900.0	2026-08-13	2026-08-13	Portas da suite e closet	54	\N	0	t	2026-08-14 16:09:56.734394	2026-08-14 16:09:56.734394	1	1	\N	2026-08-14 16:09:56.734307	1
934	63	2026-04-24	2026-06-05	Mercado Tatico	11	7	2	t	2026-04-24 12:24:29.11637	2026-05-29 11:11:17.544953	1	1	\N	2026-05-29 11:11:17.544878	1
877	38.32	2026-03-18	2026-05-03	Bermuda e Camisetas	31	10	3	t	2026-04-21 16:55:22.8428	2026-05-01 03:15:53.753752	6	2	877	2026-05-01 03:15:53.753752	1
857	210.43	2025-06-20	2026-06-05	Pix no crédito	30	9	3	t	2026-04-21 05:07:26.830209	2026-05-30 11:29:37.934237	12	12	856	2026-05-30 11:29:37.934154	1
852	39	2026-04-20	2026-05-05	Pamonha	12	9	2	t	2026-04-21 05:02:15.181876	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
853	56.98	2026-04-18	2026-05-05	Ifood	12	9	2	t	2026-04-21 05:02:52.262387	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
854	165.91	2026-04-18	2026-05-05	Remedio Tharllys	15	9	2	t	2026-04-21 05:03:22.566764	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
855	28.74	2026-04-17	2026-05-05	Pratiko	12	9	2	t	2026-04-21 05:04:34.476339	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
856	210.43	2025-06-20	2026-05-05	Pix no crédito	30	9	3	t	2026-04-21 05:07:26.826633	2026-05-02 16:21:30.94344	12	11	856	2026-05-02 16:21:30.94344	1
858	57.97	2026-03-28	2026-05-05	Ifood	12	9	2	t	2026-04-21 05:10:17.561304	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
859	36.98	2026-03-28	2026-05-05	Ifood	12	9	2	t	2026-04-21 05:10:17.564377	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
860	16.2	2026-04-01	2026-05-05	99	9	9	2	t	2026-04-21 05:11:21.124315	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
861	31.9	2026-04-05	2026-05-05	Remedio	15	9	2	t	2026-04-21 05:12:14.687475	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
862	22.48	2026-04-14	2026-05-05	Nobre Frios	11	9	2	t	2026-04-21 05:14:43.417112	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
864	111.27	2026-04-08	2026-05-05	Rb Combustveis	8	9	2	t	2026-04-21 05:14:43.423805	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
865	196.17	2026-04-17	2026-05-05	Mercado Tatico	11	9	2	t	2026-04-21 05:16:43.011704	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
866	37.3	2026-04-16	2026-05-05	99foos	12	9	2	t	2026-04-21 05:17:22.709864	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
867	20.71	2026-04-15	2026-05-05	Pratiko	12	9	2	t	2026-04-21 05:18:01.038786	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
933	33	2026-04-24	2026-05-05	Alho e Paprica	11	9	2	t	2026-04-24 12:24:29.111598	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
935	250	2026-04-23	2026-05-05	Combustível	8	9	2	t	2026-04-26 01:47:56.123527	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
868	84	2026-04-21	2026-05-04	Loteria Lotofácil 	24	5	2	t	2026-04-21 15:18:45.320732	2026-05-02 16:24:31.874246	1	1	\N	2026-05-02 16:24:31.874246	1
1323	274.57	2026-05-29	2026-05-29	Detran Taxa de Baixa de Gravame	45	\N	0	t	2026-06-01 13:48:12.032942	2026-06-01 13:58:29.368903	1	1	\N	2026-06-01 13:58:29.367309	1
863	26.87	2026-04-10	2026-05-05	Mape Farma	15	9	2	t	2026-04-21 05:14:43.419947	2026-05-12 12:31:53.864101	1	1	\N	2026-05-02 16:21:30.94344	1
874	2056.5	2023-02-28	2026-05-01	Carro	2	\N	1	t	2026-04-21 16:41:55.27358	2026-05-14 14:01:11.040795	1	1	\N	2026-05-11 20:47:56.094105	1
878	38.32	2026-03-18	2026-06-03	Bermuda e Camisetas	31	10	3	t	2026-04-21 16:55:22.846071	2026-06-02 16:42:28.727416	6	3	877	2026-06-02 16:42:28.727416	1
875	2056.5	2023-03-28	2026-05-01	Carro	2	\N	1	t	2026-04-21 16:41:55.275173	2026-05-20 17:25:11.323085	1	1	\N	2026-05-11 20:48:01.981105	1
1413	21.09	2026-06-07	2026-09-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.663571	2026-06-09 19:13:52.663571	12	3	1411	\N	1
1414	21.09	2026-06-07	2026-10-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.734873	2026-06-09 19:13:52.734873	12	4	1411	\N	1
1415	21.09	2026-06-07	2026-11-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.739323	2026-06-09 19:13:52.739323	12	5	1411	\N	1
1416	21.09	2026-06-07	2026-12-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.743321	2026-06-09 19:13:52.743321	12	6	1411	\N	1
1417	21.09	2026-06-07	2027-01-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.747167	2026-06-09 19:13:52.747167	12	7	1411	\N	1
1418	21.09	2026-06-07	2027-02-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.750531	2026-06-09 19:13:52.750531	12	8	1411	\N	1
1419	21.09	2026-06-07	2027-03-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.829547	2026-06-09 19:13:52.829547	12	9	1411	\N	1
1420	21.09	2026-06-07	2027-04-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.834015	2026-06-09 19:13:52.834015	12	10	1411	\N	1
1421	21.09	2026-06-07	2027-05-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.838013	2026-06-09 19:13:52.838013	12	11	1411	\N	1
1422	21.09	2026-06-07	2027-06-05	Amazon cafes	11	7	3	f	2026-06-09 19:13:52.842054	2026-06-09 19:13:52.842054	12	12	1411	\N	1
1405	19.89	2026-06-09	2026-06-09	Marmita Ifood	14	\N	0	t	2026-06-09 19:07:11.14606	2026-06-14 21:07:11.452148	1	1	\N	2026-06-14 21:07:11.45142	1
1410	34.98	2026-06-03	2026-06-03	Ifood	12	\N	0	t	2026-06-09 19:10:27.436873	2026-06-14 21:07:24.896129	1	1	\N	2026-06-14 21:07:24.895687	1
1406	96.17	2026-06-08	2026-06-08	Supermercado Tatico	11	\N	0	t	2026-06-09 19:07:11.245463	2026-06-14 21:07:25.994206	1	1	\N	2026-06-14 21:07:25.99401	1
873	2056.5	2023-01-28	2026-05-01	Carro	2	\N	1	t	2026-04-21 16:41:55.271595	2026-04-30 11:26:53.505688	1	1	\N	\N	1
881	38.32	2026-03-18	2026-09-03	Bermuda e Camisetas	31	10	3	f	2026-04-21 16:55:22.849269	2026-04-21 16:55:22.849269	6	6	877	\N	1
1475	23.71	2026-06-23	2026-06-23	Água	6	\N	0	t	2026-06-25 12:10:44.173855	2026-06-25 22:05:41.841017	1	1	\N	2026-06-25 22:05:41.840891	1
1477	43.64	2026-06-20	2026-06-20	99 food	12	\N	0	t	2026-06-25 12:10:44.248392	2026-06-25 22:06:19.715792	1	1	\N	2026-06-25 22:06:19.714218	1
1478	49.52	2026-06-18	2026-06-18	99 food	12	\N	0	t	2026-06-25 12:11:45.969172	2026-06-25 22:06:27.71687	1	1	\N	2026-06-25 22:06:27.716742	1
1480	29.8	2026-06-16	2026-06-16	Sebba 	54	\N	0	t	2026-06-25 12:13:13.426381	2026-06-25 22:06:32.15092	1	1	\N	2026-06-25 22:06:32.150763	1
1482	47.05	2026-06-16	2026-07-08	Ifood	12	8	2	t	2026-06-25 12:17:17.082119	2026-06-29 19:58:35.366784	1	1	\N	2026-06-29 19:58:35.366719	1
1481	41.05	2026-06-16	2026-07-08	Ifood	12	8	2	t	2026-06-25 12:17:17.065655	2026-06-29 19:58:35.978426	1	1	\N	2026-06-29 19:58:35.978355	1
1483	15.99	2026-06-18	2026-07-08	Ifood	12	8	2	t	2026-06-25 12:17:17.149522	2026-06-29 19:58:39.548088	1	1	\N	2026-06-29 19:58:39.548025	1
1212	138.1	2026-05-24	2026-07-05	Tatico	11	7	2	t	2026-05-25 13:53:49.588562	2026-06-29 19:58:55.847445	1	1	\N	2026-06-29 19:58:55.84738	1
1213	65.0	2026-05-25	2026-07-05	Fita isolante 	54	7	2	t	2026-05-25 13:53:49.709675	2026-06-29 19:58:57.354786	1	1	\N	2026-06-29 19:58:57.354716	1
1423	30.0	2026-06-05	2026-07-05	Salgados	12	7	2	t	2026-06-09 19:13:52.848262	2026-06-29 19:59:07.222278	1	1	\N	2026-06-29 19:59:07.222196	1
1411	21.09	2026-06-07	2026-07-05	Amazon cafes	11	7	3	t	2026-06-09 19:13:52.632887	2026-06-29 19:59:14.284207	12	1	1411	2026-06-29 19:59:14.284048	1
879	38.32	2026-03-18	2026-07-03	Bermuda e Camisetas	31	10	3	t	2026-04-21 16:55:22.847372	2026-07-02 00:03:35.148273	6	4	877	2026-07-02 00:03:35.148273	1
1407	73.8	2026-06-08	2026-07-13	Center Sul	54	11	2	t	2026-06-09 19:08:32.773689	2026-07-11 12:46:10.171007	1	1	\N	2026-07-11 12:46:10.171007	1
880	38.32	2026-03-18	2026-08-03	Bermuda e Camisetas	31	10	3	t	2026-04-21 16:55:22.848343	2026-08-04 13:20:20.458685	6	5	877	2026-08-04 13:20:20.458685	1
1412	21.09	2026-06-07	2026-08-05	Amazon cafes	11	7	3	t	2026-06-09 19:13:52.659596	2026-08-04 13:20:28.742767	12	2	1411	2026-08-04 13:20:28.742767	1
1476	12.0	2026-06-21	2026-08-05	Paramount	48	5	2	t	2026-06-25 12:10:44.187545	2026-08-04 13:20:32.113738	1	1	\N	2026-08-04 13:20:32.113738	1
312	30.25	2026-01-09	2026-06-04	Pia	54	5	3	t	2026-04-21 03:44:47.39605	2026-05-31 17:49:56.030145	8	5	311	2026-05-31 17:49:56.030082	1
309	14.97	2026-03-23	2026-06-04	Psyllium	18	5	3	t	2026-04-21 03:44:47.380782	2026-05-31 17:49:57.581983	4	3	308	2026-05-31 17:49:57.581926	1
303	17.26	2026-03-31	2026-06-04	Cafe	11	5	3	t	2026-04-21 03:44:47.360896	2026-05-31 17:49:59.65384	6	2	302	2026-05-31 17:49:59.653774	1
166	169.04	2026-04-08	2026-05-05	Mercado Tatico	11	7	2	t	2026-04-21 02:56:55.594257	2026-04-30 11:22:43.626706	1	1	\N	\N	1
167	23.95	2026-04-08	2026-05-05	BIG LAR	49	7	2	t	2026-04-21 02:56:55.596876	2026-04-30 11:22:41.702168	1	1	\N	\N	1
168	53.54	2026-04-06	2026-05-05	Store Supermercado	11	7	2	t	2026-04-21 02:56:55.60031	2026-04-30 11:22:49.814494	1	1	\N	\N	1
169	21.48	2026-04-03	2026-05-05	Store Supermercado	11	7	2	t	2026-04-21 02:56:55.604232	2026-04-30 11:22:52.673983	1	1	\N	\N	1
170	26.47	2026-04-02	2026-05-05	Nobre Frios	11	7	2	t	2026-04-21 02:56:55.606898	2026-04-30 11:22:56.854302	1	1	\N	\N	1
171	131.68	2026-04-02	2026-05-05	Store Supermercado	11	7	2	t	2026-04-21 02:56:55.616424	2026-04-30 11:22:54.222536	1	1	\N	\N	1
172	128.52	2026-03-25	2026-05-05	Mercado Tatico	11	7	2	t	2026-04-21 02:56:55.626983	2026-04-30 11:23:49.033196	1	1	\N	\N	1
173	140.96	2026-03-25	2026-05-05	Posto de Combustível	8	7	2	t	2026-04-21 02:56:55.637422	2026-04-30 11:23:51.053066	1	1	\N	\N	1
174	13.98	2026-03-23	2026-05-05	BIG LAR	49	7	2	t	2026-04-21 02:56:55.649585	2026-04-30 11:23:45.476637	1	1	\N	\N	1
175	70	2026-03-23	2026-05-05	Hardcore Academia	18	7	2	t	2026-04-21 02:56:55.667212	2026-04-30 11:23:47.557668	1	1	\N	\N	1
283	416.67	2026-01-09	2026-06-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.279896	2026-06-01 00:10:41.27208	12	5	282	2026-06-01 00:10:41.271811	1
276	333.33	2026-02-02	2026-09-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.23315	2026-04-21 03:44:47.23315	12	7	272	\N	1
277	333.33	2026-02-02	2026-10-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.239109	2026-04-21 03:44:47.239109	12	8	272	\N	1
278	333.33	2026-02-02	2026-11-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.244284	2026-04-21 03:44:47.244284	12	9	272	\N	1
279	333.33	2026-02-02	2026-12-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.251035	2026-04-21 03:44:47.251035	12	10	272	\N	1
280	333.33	2026-02-02	2027-01-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.257713	2026-04-21 03:44:47.257713	12	11	272	\N	1
281	333.33	2026-02-02	2027-02-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.260246	2026-04-21 03:44:47.260246	12	12	272	\N	1
292	525.98	2025-06-02	2026-06-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.302363	2026-06-01 00:10:39.421477	12	12	291	2026-06-01 00:10:39.421147	1
273	333.33	2026-02-02	2026-06-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.219443	2026-06-01 00:10:44.209406	12	4	272	2026-06-01 00:10:44.209346	1
286	416.67	2026-01-09	2026-09-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.283096	2026-04-21 03:44:47.283096	12	8	282	\N	1
287	416.67	2026-01-09	2026-10-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.284547	2026-04-21 03:44:47.284547	12	9	282	\N	1
288	416.67	2026-01-09	2026-11-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.285684	2026-04-21 03:44:47.285684	12	10	282	\N	1
289	416.67	2026-01-09	2026-12-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.287786	2026-04-21 03:44:47.287786	12	11	282	\N	1
290	416.67	2026-01-09	2027-01-07	Pix no Crédito	30	6	3	f	2026-04-21 03:44:47.289323	2026-04-21 03:44:47.289323	12	12	282	\N	1
295	28.91	2026-04-12	2026-06-04	Bota	31	5	3	t	2026-04-21 03:44:47.329263	2026-06-04 13:43:14.630691	8	2	294	2026-05-31 17:50:01.410479	1
1324	159.4	2026-06-02	2026-06-02	Pisos da cabeceira	54	\N	0	t	2026-06-02 21:33:22.339723	2026-06-02 21:45:55.346864	1	1	\N	2026-06-02 21:45:55.34447	1
306	17.26	2026-03-31	2026-09-04	Cafe	11	5	3	f	2026-04-21 03:44:47.364213	2026-04-21 04:58:53.518632	6	5	302	\N	1
307	17.26	2026-03-31	2026-10-04	Cafe	11	5	3	f	2026-04-21 03:44:47.365926	2026-04-21 04:58:53.520377	6	6	302	\N	1
165	11.9	2026-04-09	2026-05-05	AMAZON MUSIC	48	7	2	t	2026-04-21 02:56:55.591473	2026-06-04 13:47:46.820368	1	1	\N	2026-06-04 13:47:46.820045	1
315	30.25	2026-01-09	2026-09-04	Pia	54	5	3	f	2026-04-21 03:44:47.399304	2026-04-21 13:48:25.292039	8	8	311	\N	1
747	233	2028-10-01	2028-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.534702	2026-04-21 04:08:09.534702	1	1	\N	\N	1
272	333.33	2026-02-02	2026-05-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.200205	2026-05-03 01:04:50.04534	12	3	272	2026-05-03 01:04:50.04534	1
282	416.67	2026-01-09	2026-05-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.27624	2026-05-03 01:04:50.04534	12	4	282	2026-05-03 01:04:50.04534	1
291	525.99	2025-06-02	2026-05-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.299585	2026-05-03 01:04:50.04534	12	11	291	2026-05-03 01:04:50.04534	1
293	178.9	2025-04-29	2026-05-01	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.314072	2026-05-03 01:04:50.04534	12	12	293	2026-05-03 01:04:50.04534	1
1474	230.0	2026-06-24	2026-06-24	Tubos de aço	54	\N	0	t	2026-06-25 12:10:44.069266	2026-06-25 22:05:39.773422	1	1	\N	2026-06-25 22:05:39.772908	1
1479	50.0	2026-06-17	2026-06-17	Jogo Bolao	24	\N	0	t	2026-06-25 12:12:36.0157	2026-06-25 22:06:29.889687	1	1	\N	2026-06-25 22:06:29.889605	1
274	333.33	2026-02-02	2026-07-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.225228	2026-06-29 19:58:04.484962	12	5	272	2026-06-29 19:58:04.484873	1
1426	48.93	2026-06-11	2026-07-08	Store	11	8	2	t	2026-06-12 03:11:48.56268	2026-06-29 19:58:33.083682	1	1	\N	2026-06-29 19:58:33.083616	1
1425	35.48	2026-06-10	2026-07-08	Bolos Ifood 	12	8	2	t	2026-06-12 03:11:48.55521	2026-06-29 19:58:37.442657	1	1	\N	2026-06-29 19:58:37.442548	1
1424	11.28	2026-06-10	2026-07-08	99	12	8	2	t	2026-06-12 03:11:48.37019	2026-06-29 19:58:39.99441	1	1	\N	2026-06-29 19:58:39.994338	1
296	28.84	2026-04-12	2026-07-04	Bota	31	5	3	t	2026-04-21 03:44:47.330561	2026-07-02 00:39:51.740128	8	3	294	2026-07-02 00:03:40.63037	1
275	333.33	2026-02-02	2026-08-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.229289	2026-08-04 13:20:38.973086	12	6	272	2026-08-04 13:20:38.973086	1
298	28.84	2026-04-12	2026-09-04	Bota	31	5	3	f	2026-04-21 03:44:47.333182	2026-07-02 00:39:51.767698	8	5	294	\N	1
299	28.84	2026-04-12	2026-10-04	Bota	31	5	3	f	2026-04-21 03:44:47.334339	2026-07-02 00:39:51.770518	8	6	294	\N	1
1427	39.56	2026-06-11	2026-07-13	Nobre frios	12	11	2	t	2026-06-12 03:11:48.569338	2026-07-11 12:46:10.171007	1	1	\N	2026-07-11 12:46:10.171007	1
297	28.84	2026-04-12	2026-08-04	Bota	31	5	3	t	2026-04-21 03:44:47.332024	2026-08-04 13:20:32.113738	8	4	294	2026-08-04 13:20:32.113738	1
305	17.26	2026-03-31	2026-08-04	Cafe	11	5	3	t	2026-04-21 03:44:47.363054	2026-08-04 13:20:32.113738	6	4	302	2026-08-04 13:20:32.113738	1
314	30.25	2026-01-09	2026-08-04	Pia	54	5	3	t	2026-04-21 03:44:47.398237	2026-08-04 13:20:32.113738	8	7	311	2026-08-04 13:20:32.113738	1
285	416.67	2026-01-09	2026-08-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.282101	2026-08-04 13:20:38.973086	12	7	282	2026-08-04 13:20:38.973086	1
374	162.72	2025-11-27	2026-06-05	TV LG	38	7	3	t	2026-04-21 03:44:47.622006	2026-05-29 11:11:01.792229	21	6	373	2026-05-29 11:11:01.792173	1
363	41.21	2026-01-24	2026-06-05	Torneiras e torre	54	7	3	t	2026-04-21 03:44:47.596556	2026-05-29 11:11:04.644454	13	4	362	2026-05-29 11:11:04.644362	1
359	13.29	2026-03-12	2026-06-05	Potes	49	7	3	t	2026-04-21 03:44:47.578483	2026-05-29 11:11:10.639634	5	3	358	2026-05-29 11:11:10.639573	1
352	22.74	2026-03-25	2026-06-05	Grill	38	7	3	t	2026-04-21 03:44:47.559326	2026-05-29 11:11:12.696004	7	2	351	2026-05-29 11:11:12.695933	1
340	37.69	2026-03-30	2026-06-05	Barbeador	34	7	3	t	2026-04-21 03:44:47.532298	2026-05-29 11:11:15.086661	12	2	339	2026-05-29 11:11:15.086587	1
321	66.24	2026-04-05	2026-06-05	Lençol	49	9	3	t	2026-04-21 03:44:47.44698	2026-05-30 11:29:29.152157	3	2	320	2026-05-30 11:29:29.152075	1
338	203.51	2025-06-18	2026-06-05	Pix no Crédito	30	9	3	t	2026-04-21 03:44:47.516475	2026-05-30 11:29:35.797775	12	12	337	2026-05-30 11:29:35.797716	1
326	333.33	2026-02-02	2026-06-05	Pix no Crédito	30	9	3	t	2026-04-21 03:44:47.478959	2026-05-30 11:29:39.735591	12	4	325	2026-05-30 11:29:39.735505	1
324	65.1	2026-03-25	2026-06-05	Remédios	15	9	3	t	2026-04-21 03:44:47.463332	2026-05-30 11:29:46.152492	3	3	323	2026-05-30 11:29:46.152419	1
318	25.85	2025-11-17	2026-06-04	Garrafas e Tenis	18	5	3	t	2026-04-21 03:44:47.425346	2026-05-31 17:49:54.026967	8	7	317	2026-05-31 17:49:54.023253	1
1484	42.8	2026-06-25	2026-06-25	Argmassa e Cola	54	\N	0	t	2026-06-25 22:08:03.572741	2026-06-25 22:08:05.957434	1	1	\N	2026-06-25 22:08:05.957192	1
339	37.69	2026-03-30	2026-05-05	Barbeador	34	7	3	t	2026-04-21 03:44:47.527569	2026-04-30 11:23:09.823779	12	1	339	\N	1
364	41.21	2026-01-24	2026-07-05	Torneiras e torre	54	7	3	t	2026-04-21 03:44:47.597657	2026-06-29 19:59:02.313834	13	5	362	2026-06-29 19:59:02.313776	1
343	37.69	2026-03-30	2026-09-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.535648	2026-04-21 03:44:47.535648	12	5	339	\N	1
344	37.69	2026-03-30	2026-10-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.536992	2026-04-21 03:44:47.536992	12	6	339	\N	1
345	37.69	2026-03-30	2026-11-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.538241	2026-04-21 03:44:47.538241	12	7	339	\N	1
346	37.69	2026-03-30	2026-12-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.540048	2026-04-21 03:44:47.540048	12	8	339	\N	1
347	37.69	2026-03-30	2027-01-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.541168	2026-04-21 03:44:47.541168	12	9	339	\N	1
348	37.69	2026-03-30	2027-02-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.542381	2026-04-21 03:44:47.542381	12	10	339	\N	1
349	37.69	2026-03-30	2027-03-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.543419	2026-04-21 03:44:47.543419	12	11	339	\N	1
350	37.69	2026-03-30	2027-04-05	Barbeador	34	7	3	f	2026-04-21 03:44:47.544479	2026-04-21 03:44:47.544479	12	12	339	\N	1
351	22.74	2026-03-25	2026-05-05	Grill	38	7	3	t	2026-04-21 03:44:47.556258	2026-04-30 11:23:57.652241	7	1	351	\N	1
341	37.69	2026-03-30	2026-07-05	Barbeador	34	7	3	t	2026-04-21 03:44:47.53337	2026-06-29 19:59:04.31462	12	3	339	2026-06-29 19:59:04.314551	1
355	22.74	2026-03-25	2026-09-05	Grill	38	7	3	f	2026-04-21 03:44:47.562989	2026-04-21 03:44:47.562989	7	5	351	\N	1
356	22.74	2026-03-25	2026-10-05	Grill	38	7	3	f	2026-04-21 03:44:47.563989	2026-04-21 03:44:47.563989	7	6	351	\N	1
357	22.74	2026-03-25	2026-11-05	Grill	38	7	3	f	2026-04-21 03:44:47.56498	2026-04-21 03:44:47.56498	7	7	351	\N	1
358	13.29	2026-03-12	2026-05-05	Potes	49	7	3	t	2026-04-21 03:44:47.575982	2026-04-30 11:23:41.191137	5	2	358	\N	1
353	22.74	2026-03-25	2026-07-05	Grill	38	7	3	t	2026-04-21 03:44:47.560394	2026-06-29 19:59:12.427505	7	3	351	2026-06-29 19:59:12.427447	1
362	41.21	2026-01-24	2026-05-05	Torneiras e torre	54	7	3	t	2026-04-21 03:44:47.593969	2026-04-30 11:23:28.697206	13	3	362	\N	1
360	13.29	2026-03-12	2026-07-05	Potes	49	7	3	t	2026-04-21 03:44:47.579489	2026-06-29 19:59:19.071219	5	4	358	2026-06-29 19:59:19.071144	1
366	41.21	2026-01-24	2026-09-05	Torneiras e torre	54	7	3	f	2026-04-21 03:44:47.59972	2026-04-21 13:47:58.716485	13	7	362	\N	1
367	41.21	2026-01-24	2026-10-05	Torneiras e torre	54	7	3	f	2026-04-21 03:44:47.600939	2026-04-21 13:47:58.720097	13	8	362	\N	1
368	41.21	2026-01-24	2026-11-05	Torneiras e torre	54	7	3	f	2026-04-21 03:44:47.602057	2026-04-21 13:47:58.721498	13	9	362	\N	1
369	41.21	2026-01-24	2026-12-05	Torneiras e torre	54	7	3	f	2026-04-21 03:44:47.603266	2026-04-21 13:47:58.722539	13	10	362	\N	1
370	41.21	2026-01-24	2027-01-05	Torneiras e torre	54	7	3	f	2026-04-21 03:44:47.604297	2026-04-21 13:47:58.723627	13	11	362	\N	1
371	41.21	2026-01-24	2027-02-05	Torneiras e torre	54	7	3	f	2026-04-21 03:44:47.605307	2026-04-21 13:47:58.724626	13	12	362	\N	1
372	41.21	2026-01-24	2027-03-05	Torneiras e torre	54	7	3	f	2026-04-21 03:44:47.606377	2026-04-21 13:47:58.725993	13	13	362	\N	1
373	162.72	2025-11-27	2026-05-05	TV LG	38	7	3	t	2026-04-21 03:44:47.61834	2026-04-30 11:23:18.547942	21	5	373	\N	1
319	25.85	2025-11-17	2026-07-04	Garrafas e Tenis	18	5	3	t	2026-04-21 03:44:47.42662	2026-07-02 00:03:40.63037	8	8	317	2026-07-02 00:03:40.63037	1
317	25.85	2025-11-17	2026-05-04	Garrafas e Tenis	18	5	3	t	2026-04-21 03:44:47.422139	2026-05-02 16:24:31.874246	8	6	317	2026-05-02 16:24:31.874246	1
322	66.24	2026-04-05	2026-07-05	Lençol	49	9	3	t	2026-04-21 03:44:47.448201	2026-07-02 00:03:43.876536	3	3	320	2026-07-02 00:03:43.876536	1
327	333.33	2026-02-02	2026-07-05	Pix no Crédito	30	9	3	t	2026-04-21 03:44:47.480357	2026-07-02 00:03:43.876536	12	5	325	2026-07-02 00:03:43.876536	1
1514	1950.0	2026-07-04	2026-07-04	Entrada pedras	54	\N	0	t	2026-07-07 23:49:09.905175	2026-07-07 23:50:19.463635	1	1	\N	2026-07-07 23:50:19.463345	1
1515	1742.0	2026-07-08	2026-07-08	Resto das pedras do mala	54	\N	0	t	2026-07-07 23:49:09.939768	2026-07-28 18:27:11.946056	1	1	\N	2026-07-28 18:27:11.945908	1
1428	21.0	2026-06-09	2026-07-13	Pamonha	12	11	2	t	2026-06-12 03:13:26.338958	2026-07-11 12:46:10.171007	1	1	\N	2026-07-11 12:46:10.171007	1
1591	23.74	2026-07-20	2026-07-20	Água	6	\N	0	t	2026-08-04 13:14:22.579259	2026-08-04 13:14:22.579259	1	1	\N	2026-08-04 13:14:22.579204	1
1445	50.0	2026-06-14	2026-08-08	Pix no Crédito Caixa	30	8	3	t	2026-06-14 21:35:38.854031	2026-08-04 13:20:24.419771	10	2	1444	2026-08-04 13:20:24.419771	1
328	333.33	2026-02-02	2026-08-05	Pix no Crédito	30	9	3	t	2026-04-21 03:44:47.481499	2026-08-04 13:20:36.282873	12	6	325	2026-08-04 13:20:36.282873	1
377	162.72	2025-11-27	2026-09-05	TV LG	38	7	3	f	2026-04-21 03:44:47.626367	2026-04-21 03:44:47.626367	21	9	373	\N	1
378	162.72	2025-11-27	2026-10-05	TV LG	38	7	3	f	2026-04-21 03:44:47.627418	2026-04-21 03:44:47.627418	21	10	373	\N	1
379	162.72	2025-11-27	2026-11-05	TV LG	38	7	3	f	2026-04-21 03:44:47.628432	2026-04-21 03:44:47.628432	21	11	373	\N	1
380	162.72	2025-11-27	2026-12-05	TV LG	38	7	3	f	2026-04-21 03:44:47.629408	2026-04-21 03:44:47.629408	21	12	373	\N	1
381	162.72	2025-11-27	2027-01-05	TV LG	38	7	3	f	2026-04-21 03:44:47.630454	2026-04-21 03:44:47.630454	21	13	373	\N	1
382	162.72	2025-11-27	2027-02-05	TV LG	38	7	3	f	2026-04-21 03:44:47.632093	2026-04-21 03:44:47.632093	21	14	373	\N	1
383	162.72	2025-11-27	2027-03-05	TV LG	38	7	3	f	2026-04-21 03:44:47.633243	2026-04-21 03:44:47.633243	21	15	373	\N	1
384	162.72	2025-11-27	2027-04-05	TV LG	38	7	3	f	2026-04-21 03:44:47.6344	2026-04-21 03:44:47.6344	21	16	373	\N	1
385	162.72	2025-11-27	2027-05-05	TV LG	38	7	3	f	2026-04-21 03:44:47.635409	2026-04-21 03:44:47.635409	21	17	373	\N	1
386	162.72	2025-11-27	2027-06-05	TV LG	38	7	3	f	2026-04-21 03:44:47.63645	2026-04-21 03:44:47.63645	21	18	373	\N	1
387	162.72	2025-11-27	2027-07-05	TV LG	38	7	3	f	2026-04-21 03:44:47.637488	2026-04-21 03:44:47.637488	21	19	373	\N	1
388	162.72	2025-11-27	2027-08-05	TV LG	38	7	3	f	2026-04-21 03:44:47.638928	2026-04-21 03:44:47.638928	21	20	373	\N	1
389	162.72	2025-11-27	2027-09-05	TV LG	38	7	3	f	2026-04-21 03:44:47.639974	2026-04-21 03:44:47.639974	21	21	373	\N	1
390	37.95	2025-12-18	2026-05-05	Garantia Estendida da TV	48	7	3	t	2026-04-21 03:44:47.650801	2026-04-30 11:23:25.286865	6	6	390	\N	1
392	33.86	2026-03-04	2026-05-05	Condimentos e Cafe	11	7	3	t	2026-04-21 03:46:22.171979	2026-04-30 11:23:32.434111	12	2	392	\N	1
391	94.85	2025-03-13	2026-05-05	Panelas	55	7	3	t	2026-04-21 03:44:47.662667	2026-06-04 13:42:44.233399	14	14	391	2026-06-04 13:42:44.232993	1
396	33.86	2026-03-04	2026-09-05	Condimentos e Cafe	11	7	3	f	2026-04-21 03:46:22.217083	2026-04-21 03:46:22.217083	12	6	392	\N	1
397	33.86	2026-03-04	2026-10-05	Condimentos e Cafe	11	7	3	f	2026-04-21 03:46:22.218171	2026-04-21 03:46:22.218171	12	7	392	\N	1
398	33.86	2026-03-04	2026-11-05	Condimentos e Cafe	11	7	3	f	2026-04-21 03:46:22.219163	2026-04-21 03:46:22.219163	12	8	392	\N	1
399	33.86	2026-03-04	2026-12-05	Condimentos e Cafe	11	7	3	f	2026-04-21 03:46:22.220874	2026-04-21 03:46:22.220874	12	9	392	\N	1
400	33.86	2026-03-04	2027-01-05	Condimentos e Cafe	11	7	3	f	2026-04-21 03:46:22.221956	2026-04-21 03:46:22.221956	12	10	392	\N	1
401	33.86	2026-03-04	2027-02-05	Condimentos e Cafe	11	7	3	f	2026-04-21 03:46:22.222985	2026-04-21 03:46:22.222985	12	11	392	\N	1
402	33.86	2026-03-04	2027-03-05	Condimentos e Cafe	11	7	3	f	2026-04-21 03:46:22.224136	2026-04-21 03:46:22.224136	12	12	392	\N	1
434	889.85	2026-06-01	2026-06-01	Plano de Saúde	17	\N	0	t	2026-04-21 04:01:20.981516	2026-05-29 11:07:49.31037	1	1	\N	2026-05-29 11:07:49.30971	1
393	33.86	2026-03-04	2026-06-05	Condimentos e Cafe	11	7	3	t	2026-04-21 03:46:22.213202	2026-05-29 11:11:06.934246	12	3	392	2026-05-29 11:11:06.934178	1
406	1200	2026-07-01	2026-07-01	Aluguel	3	\N	0	t	2026-04-21 03:55:13.018549	2026-07-02 00:16:02.636144	1	1	\N	2026-07-02 00:16:02.636068	1
1331	55.86	2026-05-31	2026-07-08	Salgados 99	12	8	2	t	2026-06-02 22:06:29.897686	2026-06-29 19:58:29.785492	1	1	\N	2026-06-29 19:58:29.785426	1
405	1200	2026-06-01	2026-06-01	Aluguel	3	\N	0	t	2026-04-21 03:55:13.015552	2026-05-31 17:43:04.099723	1	1	\N	2026-05-31 17:43:04.099421	1
417	109.7	2026-06-01	2026-06-01	Água	6	\N	0	t	2026-04-21 04:01:20.932675	2026-06-01 14:06:56.605221	1	1	\N	2026-06-01 14:06:56.604335	1
375	162.72	2025-11-27	2026-07-05	TV LG	38	7	3	t	2026-04-21 03:44:47.623814	2026-06-29 19:58:53.08222	21	7	373	2026-06-29 19:58:53.082137	1
413	500	2026-09-02	2026-09-02	Energia	5	\N	0	f	2026-04-21 04:01:20.920496	2026-04-21 04:01:20.920496	1	1	\N	\N	1
414	500	2026-10-02	2026-10-02	Energia	5	\N	0	f	2026-04-21 04:01:20.925508	2026-04-21 04:01:20.925508	1	1	\N	\N	1
415	500	2026-11-02	2026-11-02	Energia	5	\N	0	f	2026-04-21 04:01:20.928226	2026-04-21 04:01:20.928226	1	1	\N	\N	1
394	33.86	2026-03-04	2026-07-05	Condimentos e Cafe	11	7	3	t	2026-04-21 03:46:22.214546	2026-06-29 19:59:06.147601	12	4	392	2026-06-29 19:59:06.147545	1
1330	2000.0	2026-08-20	2026-08-20	Portas do Banheiro	54	\N	0	t	2026-06-02 21:55:51.295433	2026-07-28 18:29:21.11977	1	1	\N	2026-07-28 18:29:21.119706	1
435	893.84	2026-07-01	2026-07-01	Plano de Saúde	17	\N	0	t	2026-04-21 04:01:20.983628	2026-06-29 20:01:52.751991	1	1	\N	2026-06-29 20:01:52.751918	1
427	230	2026-07-11	2026-07-11	Internet	37	\N	1	t	2026-04-21 04:01:20.962384	2026-07-11 12:44:14.991582	1	1	\N	2026-07-11 12:44:14.991221	1
421	130	2026-09-02	2026-09-02	Água	6	\N	0	f	2026-04-21 04:01:20.946257	2026-04-21 04:01:20.946257	1	1	\N	\N	1
422	130	2026-10-02	2026-10-02	Água	6	\N	0	f	2026-04-21 04:01:20.948352	2026-04-21 04:01:20.948352	1	1	\N	\N	1
423	130	2026-11-02	2026-11-02	Água	6	\N	0	f	2026-04-21 04:01:20.950352	2026-04-21 04:01:20.950352	1	1	\N	\N	1
424	130	2026-12-02	2026-12-02	Água	6	\N	0	f	2026-04-21 04:01:20.952374	2026-04-21 04:01:20.952374	1	1	\N	\N	1
418	121.23	2026-06-01	2026-06-01	Água	6	\N	0	t	2026-04-21 04:01:20.93563	2026-06-01 14:07:34.004404	1	1	\N	2026-06-01 14:07:34.004346	1
429	230	2026-09-11	2026-09-11	Internet	37	\N	1	f	2026-04-21 04:01:20.966841	2026-04-21 04:01:20.966841	1	1	\N	\N	1
430	230	2026-10-11	2026-10-11	Internet	37	\N	1	f	2026-04-21 04:01:20.969238	2026-04-21 04:01:20.969238	1	1	\N	\N	1
431	230	2026-11-11	2026-11-11	Internet	37	\N	1	f	2026-04-21 04:01:20.972135	2026-04-21 04:01:20.972135	1	1	\N	\N	1
432	230	2026-12-11	2026-12-11	Internet	37	\N	1	f	2026-04-21 04:01:20.976777	2026-04-21 04:01:20.976777	1	1	\N	\N	1
410	440.85	2026-06-02	2026-06-02	Energia	5	\N	0	t	2026-04-21 04:01:20.914149	2026-06-01 15:17:00.512001	1	1	\N	2026-06-01 15:17:00.511782	1
412	387.24	2026-08-02	2026-08-02	Energia	5	\N	0	t	2026-04-21 04:01:20.918371	2026-08-04 13:00:42.399239	1	1	\N	2026-08-04 13:00:42.398759	1
437	813	2026-09-01	2026-09-01	Plano de Saúde	17	\N	0	f	2026-04-21 04:01:20.993426	2026-04-21 04:01:20.993426	1	1	\N	\N	1
433	813	2026-05-01	2026-05-01	Plano de Saúde	17	\N	0	t	2026-04-21 04:01:20.979365	2026-05-02 16:25:24.246588	1	1	\N	2026-05-02 16:25:24.246393	1
404	1200	2026-05-01	2026-05-01	Aluguel	3	\N	0	t	2026-04-21 03:55:13.012554	2026-05-02 16:25:46.022177	1	1	\N	2026-05-02 16:25:46.020931	1
409	456.88	2026-05-02	2026-05-02	Energia Aluguel 	5	\N	0	t	2026-04-21 04:01:20.911564	2026-05-03 01:16:09.646059	1	1	\N	2026-05-03 01:14:35.966149	1
419	17.46	2026-06-01	2026-06-01	Água	6	\N	0	t	2026-04-21 04:01:20.939627	2026-06-01 14:12:34.007408	1	1	\N	2026-06-01 14:12:34.007231	1
425	230	2026-05-11	2026-05-11	Internet	37	\N	1	t	2026-04-21 04:01:20.955452	2026-05-11 14:24:38.240245	1	1	\N	2026-05-11 14:24:38.24001	1
416	27.69	2026-06-01	2026-06-01	Energia	5	\N	0	t	2026-04-21 04:01:20.930519	2026-06-01 15:18:39.02499	1	1	\N	2026-06-01 15:18:39.024909	1
436	902.84	2026-08-01	2026-08-01	Plano de Saúde	17	\N	0	t	2026-04-21 04:01:20.988072	2026-08-04 13:20:07.32348	1	1	\N	2026-08-04 13:20:07.323408	1
376	162.72	2025-11-27	2026-08-05	TV LG	38	7	3	t	2026-04-21 03:44:47.625127	2026-08-04 13:20:28.742767	21	8	373	2026-08-04 13:20:28.742767	1
428	230	2026-08-11	2026-08-11	Internet	37	\N	1	t	2026-04-21 04:01:20.964505	2026-08-21 12:37:56.957555	1	1	\N	2026-08-21 12:37:56.95749	1
438	813	2026-10-01	2026-10-01	Plano de Saúde	17	\N	0	f	2026-04-21 04:01:20.995956	2026-04-21 04:01:20.995956	1	1	\N	\N	1
439	813	2026-11-01	2026-11-01	Plano de Saúde	17	\N	0	f	2026-04-21 04:01:20.998965	2026-04-21 04:01:20.998965	1	1	\N	\N	1
440	813	2026-12-01	2026-12-01	Plano de Saúde	17	\N	0	f	2026-04-21 04:01:21.001028	2026-04-21 04:01:21.001028	1	1	\N	\N	1
441	813	2027-01-01	2027-01-01	Plano de Saúde	17	\N	0	f	2026-04-21 04:01:21.003084	2026-04-21 04:01:21.003084	1	1	\N	\N	1
442	813	2027-02-01	2027-02-01	Plano de Saúde	17	\N	0	f	2026-04-21 04:01:21.00657	2026-04-21 04:01:21.00657	1	1	\N	\N	1
443	113	2026-05-27	2026-05-27	Plano Odonto	17	\N	0	t	2026-04-21 04:01:21.011779	2026-04-30 11:27:12.776513	1	1	\N	\N	1
459	180	2026-08-01	2026-08-01	INSS Mãe	45	\N	1	t	2026-04-21 04:01:21.053933	2026-08-21 12:49:13.697558	1	1	\N	2026-08-21 12:49:13.697502	1
447	113	2026-09-27	2026-09-27	Plano Odonto	17	\N	0	f	2026-04-21 04:01:21.021822	2026-04-21 04:01:21.021822	1	1	\N	\N	1
456	180	2026-05-01	2026-05-01	INSS Mãe	45	\N	1	t	2026-04-21 04:01:21.04691	2026-06-02 21:41:50.797321	1	1	\N	2026-06-02 21:41:50.79691	1
452	40	2026-09-10	2026-09-10	Claro	36	\N	1	f	2026-04-21 04:01:21.035632	2026-04-21 13:52:19.091716	1	1	\N	\N	1
453	40	2026-10-10	2026-10-10	Claro	36	\N	1	f	2026-04-21 04:01:21.03828	2026-04-21 13:52:24.854962	1	1	\N	\N	1
454	40	2026-11-10	2026-11-10	Claro	36	\N	1	f	2026-04-21 04:01:21.042213	2026-04-21 13:52:29.00461	1	1	\N	\N	1
455	40	2026-12-10	2026-12-10	Claro	36	\N	1	f	2026-04-21 04:01:21.044708	2026-04-21 13:52:09.605388	1	1	\N	\N	1
460	180	2026-09-01	2026-09-01	INSS Mãe	45	\N	1	f	2026-04-21 04:01:21.059017	2026-04-21 04:01:21.059017	1	1	\N	\N	1
461	180	2026-10-01	2026-10-01	INSS Mãe	45	\N	1	f	2026-04-21 04:01:21.063928	2026-04-21 04:01:21.063928	1	1	\N	\N	1
462	180	2026-11-01	2026-11-01	INSS Mãe	45	\N	1	f	2026-04-21 04:01:21.06826	2026-04-21 04:01:21.06826	1	1	\N	\N	1
463	180	2026-12-01	2026-12-01	INSS Mãe	45	\N	1	f	2026-04-21 04:01:21.072926	2026-04-21 04:01:21.072926	1	1	\N	\N	1
464	3223.79	2026-05-01	2026-05-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:08.775395	2026-04-30 11:28:00.075478	1	1	\N	\N	1
468	3223.79	2026-09-01	2026-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.794813	2026-04-21 04:08:08.794813	1	1	\N	\N	1
469	3223.79	2026-10-01	2026-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.797951	2026-04-21 04:08:08.797951	1	1	\N	\N	1
470	3223.79	2026-11-01	2026-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.800153	2026-04-21 04:08:08.800153	1	1	\N	\N	1
471	3223.79	2026-12-01	2026-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.802435	2026-04-21 04:08:08.802435	1	1	\N	\N	1
472	3223.79	2027-01-01	2027-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.805398	2026-04-21 04:08:08.805398	1	1	\N	\N	1
473	3223.79	2027-02-01	2027-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.807792	2026-04-21 04:08:08.807792	1	1	\N	\N	1
474	3223.79	2027-03-01	2027-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.810916	2026-04-21 04:08:08.810916	1	1	\N	\N	1
475	3223.79	2027-04-01	2027-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.813486	2026-04-21 04:08:08.813486	1	1	\N	\N	1
476	3223.79	2027-05-01	2027-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.817047	2026-04-21 04:08:08.817047	1	1	\N	\N	1
477	3223.79	2027-06-01	2027-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.820269	2026-04-21 04:08:08.820269	1	1	\N	\N	1
478	3223.79	2027-07-01	2027-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.822758	2026-04-21 04:08:08.822758	1	1	\N	\N	1
479	3223.79	2027-08-01	2027-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.825478	2026-04-21 04:08:08.825478	1	1	\N	\N	1
480	3223.79	2027-09-01	2027-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.828733	2026-04-21 04:08:08.828733	1	1	\N	\N	1
481	3223.79	2027-10-01	2027-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.831117	2026-04-21 04:08:08.831117	1	1	\N	\N	1
482	3223.79	2027-11-01	2027-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.833238	2026-04-21 04:08:08.833238	1	1	\N	\N	1
483	3223.79	2027-12-01	2027-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.835695	2026-04-21 04:08:08.835695	1	1	\N	\N	1
484	3223.79	2028-01-01	2028-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.838206	2026-04-21 04:08:08.838206	1	1	\N	\N	1
485	3223.79	2028-02-01	2028-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.840484	2026-04-21 04:08:08.840484	1	1	\N	\N	1
486	3223.79	2028-03-01	2028-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.843228	2026-04-21 04:08:08.843228	1	1	\N	\N	1
487	3223.79	2028-04-01	2028-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.845419	2026-04-21 04:08:08.845419	1	1	\N	\N	1
488	3223.79	2028-05-01	2028-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.847874	2026-04-21 04:08:08.847874	1	1	\N	\N	1
489	3223.79	2028-06-01	2028-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.849989	2026-04-21 04:08:08.849989	1	1	\N	\N	1
490	3223.79	2028-07-01	2028-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.853904	2026-04-21 04:08:08.853904	1	1	\N	\N	1
491	3223.79	2028-08-01	2028-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.856066	2026-04-21 04:08:08.856066	1	1	\N	\N	1
492	3223.79	2028-09-01	2028-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.858384	2026-04-21 04:08:08.858384	1	1	\N	\N	1
493	3223.79	2028-10-01	2028-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.860801	2026-04-21 04:08:08.860801	1	1	\N	\N	1
494	3223.79	2028-11-01	2028-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.86311	2026-04-21 04:08:08.86311	1	1	\N	\N	1
495	3223.79	2028-12-01	2028-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.865191	2026-04-21 04:08:08.865191	1	1	\N	\N	1
496	3223.79	2029-01-01	2029-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.867783	2026-04-21 04:08:08.867783	1	1	\N	\N	1
497	3223.79	2029-02-01	2029-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.870398	2026-04-21 04:08:08.870398	1	1	\N	\N	1
498	3223.79	2029-03-01	2029-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.872667	2026-04-21 04:08:08.872667	1	1	\N	\N	1
499	3223.79	2029-04-01	2029-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.874927	2026-04-21 04:08:08.874927	1	1	\N	\N	1
500	3223.79	2029-05-01	2029-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.877481	2026-04-21 04:08:08.877481	1	1	\N	\N	1
448	40	2026-05-10	2026-05-10	Claro	36	\N	1	t	2026-04-21 04:01:21.026475	2026-05-11 14:24:45.573277	1	1	\N	2026-05-11 14:24:45.573111	1
449	40	2026-06-10	2026-06-10	Claro	36	\N	1	t	2026-04-21 04:01:21.029023	2026-06-02 22:13:42.41928	1	1	\N	2026-06-02 22:13:42.419208	1
457	180	2026-06-01	2026-06-01	INSS Mãe	45	\N	1	t	2026-04-21 04:01:21.049199	2026-06-02 22:19:03.426027	1	1	\N	2026-06-02 22:19:03.425971	1
444	113	2026-06-27	2026-06-27	Plano Odonto	17	\N	0	t	2026-04-21 04:01:21.014117	2026-06-03 10:47:44.02716	1	1	\N	2026-06-03 10:47:44.02678	1
445	113	2026-07-27	2026-07-27	Plano Odonto	17	\N	0	t	2026-04-21 04:01:21.016963	2026-06-29 20:01:11.290316	1	1	\N	2026-06-29 20:01:11.290226	1
466	3223.79	2026-07-01	2026-07-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:08.787738	2026-06-29 20:05:31.891925	1	1	\N	2026-06-29 20:05:31.89166	1
450	40	2026-07-10	2026-07-10	Claro	36	\N	1	t	2026-04-21 04:01:21.03154	2026-07-11 12:44:23.683151	1	1	\N	2026-07-11 12:44:23.683083	1
467	3223.79	2026-08-01	2026-08-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:08.790396	2026-08-04 13:26:47.829434	1	1	\N	2026-08-04 13:26:47.829373	1
451	40	2026-08-10	2026-08-10	Claro	36	\N	1	t	2026-04-21 04:01:21.033661	2026-08-14 16:08:39.776999	1	1	\N	2026-08-14 16:08:39.775815	1
446	113	2026-08-27	2026-08-27	Plano Odonto	17	\N	0	t	2026-04-21 04:01:21.019202	2026-08-21 12:39:45.065942	1	1	\N	2026-08-21 12:39:45.065855	1
501	3223.79	2029-06-01	2029-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.879777	2026-04-21 04:08:08.879777	1	1	\N	\N	1
502	3223.79	2029-07-01	2029-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.881905	2026-04-21 04:08:08.881905	1	1	\N	\N	1
503	3223.79	2029-08-01	2029-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.88772	2026-04-21 04:08:08.88772	1	1	\N	\N	1
504	3223.79	2029-09-01	2029-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.89048	2026-04-21 04:08:08.89048	1	1	\N	\N	1
505	3223.79	2029-10-01	2029-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.893002	2026-04-21 04:08:08.893002	1	1	\N	\N	1
506	3223.79	2029-11-01	2029-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.89547	2026-04-21 04:08:08.89547	1	1	\N	\N	1
507	3223.79	2029-12-01	2029-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.898224	2026-04-21 04:08:08.898224	1	1	\N	\N	1
508	3223.79	2030-01-01	2030-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.900475	2026-04-21 04:08:08.900475	1	1	\N	\N	1
509	3223.79	2030-02-01	2030-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.902941	2026-04-21 04:08:08.902941	1	1	\N	\N	1
510	3223.79	2030-03-01	2030-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.90544	2026-04-21 04:08:08.90544	1	1	\N	\N	1
511	3223.79	2030-04-01	2030-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.907605	2026-04-21 04:08:08.907605	1	1	\N	\N	1
512	3223.79	2030-05-01	2030-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.91013	2026-04-21 04:08:08.91013	1	1	\N	\N	1
513	3223.79	2030-06-01	2030-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.912269	2026-04-21 04:08:08.912269	1	1	\N	\N	1
514	3223.79	2030-07-01	2030-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.914924	2026-04-21 04:08:08.914924	1	1	\N	\N	1
515	3223.79	2030-08-01	2030-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.917132	2026-04-21 04:08:08.917132	1	1	\N	\N	1
516	3223.79	2030-09-01	2030-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.91962	2026-04-21 04:08:08.91962	1	1	\N	\N	1
517	3223.79	2030-10-01	2030-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.921796	2026-04-21 04:08:08.921796	1	1	\N	\N	1
518	3223.79	2030-11-01	2030-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.924349	2026-04-21 04:08:08.924349	1	1	\N	\N	1
519	3223.79	2030-12-01	2030-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.926842	2026-04-21 04:08:08.926842	1	1	\N	\N	1
520	3223.79	2031-01-01	2031-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.929017	2026-04-21 04:08:08.929017	1	1	\N	\N	1
521	3223.79	2031-02-01	2031-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.931175	2026-04-21 04:08:08.931175	1	1	\N	\N	1
522	3223.79	2031-03-01	2031-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.933393	2026-04-21 04:08:08.933393	1	1	\N	\N	1
523	3223.79	2031-04-01	2031-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.935533	2026-04-21 04:08:08.935533	1	1	\N	\N	1
524	3223.79	2031-05-01	2031-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.937786	2026-04-21 04:08:08.937786	1	1	\N	\N	1
525	3223.79	2031-06-01	2031-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.93992	2026-04-21 04:08:08.93992	1	1	\N	\N	1
526	3223.79	2031-07-01	2031-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.942646	2026-04-21 04:08:08.942646	1	1	\N	\N	1
527	3223.79	2031-08-01	2031-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.945707	2026-04-21 04:08:08.945707	1	1	\N	\N	1
528	3223.79	2031-09-01	2031-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.948158	2026-04-21 04:08:08.948158	1	1	\N	\N	1
529	3223.79	2031-10-01	2031-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.950415	2026-04-21 04:08:08.950415	1	1	\N	\N	1
530	3223.79	2031-11-01	2031-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.952787	2026-04-21 04:08:08.952787	1	1	\N	\N	1
531	3223.79	2031-12-01	2031-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.954997	2026-04-21 04:08:08.954997	1	1	\N	\N	1
532	3223.79	2032-01-01	2032-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.956972	2026-04-21 04:08:08.956972	1	1	\N	\N	1
533	3223.79	2032-02-01	2032-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.959348	2026-04-21 04:08:08.959348	1	1	\N	\N	1
534	3223.79	2032-03-01	2032-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.962128	2026-04-21 04:08:08.962128	1	1	\N	\N	1
535	3223.79	2032-04-01	2032-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.964264	2026-04-21 04:08:08.964264	1	1	\N	\N	1
536	3223.79	2032-05-01	2032-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.966281	2026-04-21 04:08:08.966281	1	1	\N	\N	1
537	3223.79	2032-06-01	2032-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.9682	2026-04-21 04:08:08.9682	1	1	\N	\N	1
538	3223.79	2032-07-01	2032-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.970424	2026-04-21 04:08:08.970424	1	1	\N	\N	1
539	3223.79	2032-08-01	2032-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.972483	2026-04-21 04:08:08.972483	1	1	\N	\N	1
540	3223.79	2032-09-01	2032-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.97738	2026-04-21 04:08:08.97738	1	1	\N	\N	1
541	3223.79	2032-10-01	2032-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.980413	2026-04-21 04:08:08.980413	1	1	\N	\N	1
542	3223.79	2032-11-01	2032-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.982582	2026-04-21 04:08:08.982582	1	1	\N	\N	1
543	3223.79	2032-12-01	2032-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.984727	2026-04-21 04:08:08.984727	1	1	\N	\N	1
544	3223.79	2033-01-01	2033-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.987927	2026-04-21 04:08:08.987927	1	1	\N	\N	1
545	3223.79	2033-02-01	2033-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.990202	2026-04-21 04:08:08.990202	1	1	\N	\N	1
546	3223.79	2033-03-01	2033-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.993256	2026-04-21 04:08:08.993256	1	1	\N	\N	1
547	3223.79	2033-04-01	2033-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.996573	2026-04-21 04:08:08.996573	1	1	\N	\N	1
548	3223.79	2033-05-01	2033-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:08.998958	2026-04-21 04:08:08.998958	1	1	\N	\N	1
549	3223.79	2033-06-01	2033-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.001044	2026-04-21 04:08:09.001044	1	1	\N	\N	1
550	3223.79	2033-07-01	2033-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.003517	2026-04-21 04:08:09.003517	1	1	\N	\N	1
551	3223.79	2033-08-01	2033-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.006324	2026-04-21 04:08:09.006324	1	1	\N	\N	1
552	3223.79	2033-09-01	2033-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.009071	2026-04-21 04:08:09.009071	1	1	\N	\N	1
553	3223.79	2033-10-01	2033-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.011613	2026-04-21 04:08:09.011613	1	1	\N	\N	1
554	3223.79	2033-11-01	2033-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.013751	2026-04-21 04:08:09.013751	1	1	\N	\N	1
555	3223.79	2033-12-01	2033-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.016207	2026-04-21 04:08:09.016207	1	1	\N	\N	1
556	3223.79	2034-01-01	2034-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.018242	2026-04-21 04:08:09.018242	1	1	\N	\N	1
557	3223.79	2034-02-01	2034-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.020626	2026-04-21 04:08:09.020626	1	1	\N	\N	1
558	3223.79	2034-03-01	2034-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.022724	2026-04-21 04:08:09.022724	1	1	\N	\N	1
559	3223.79	2034-04-01	2034-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.025153	2026-04-21 04:08:09.025153	1	1	\N	\N	1
560	3223.79	2034-05-01	2034-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.027588	2026-04-21 04:08:09.027588	1	1	\N	\N	1
561	3223.79	2034-06-01	2034-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.029766	2026-04-21 04:08:09.029766	1	1	\N	\N	1
562	3223.79	2034-07-01	2034-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.031746	2026-04-21 04:08:09.031746	1	1	\N	\N	1
563	3223.79	2034-08-01	2034-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.033881	2026-04-21 04:08:09.033881	1	1	\N	\N	1
564	3223.79	2034-09-01	2034-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.036576	2026-04-21 04:08:09.036576	1	1	\N	\N	1
565	3223.79	2034-10-01	2034-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.03882	2026-04-21 04:08:09.03882	1	1	\N	\N	1
566	3223.79	2034-11-01	2034-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.040977	2026-04-21 04:08:09.040977	1	1	\N	\N	1
567	3223.79	2034-12-01	2034-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.043303	2026-04-21 04:08:09.043303	1	1	\N	\N	1
568	3223.79	2035-01-01	2035-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.045617	2026-04-21 04:08:09.045617	1	1	\N	\N	1
569	3223.79	2035-02-01	2035-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.047557	2026-04-21 04:08:09.047557	1	1	\N	\N	1
570	3223.79	2035-03-01	2035-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.049499	2026-04-21 04:08:09.049499	1	1	\N	\N	1
571	3223.79	2035-04-01	2035-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.051449	2026-04-21 04:08:09.051449	1	1	\N	\N	1
572	3223.79	2035-05-01	2035-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.053799	2026-04-21 04:08:09.053799	1	1	\N	\N	1
573	3223.79	2035-06-01	2035-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.056008	2026-04-21 04:08:09.056008	1	1	\N	\N	1
574	3223.79	2035-07-01	2035-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.058002	2026-04-21 04:08:09.058002	1	1	\N	\N	1
575	3223.79	2035-08-01	2035-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.060538	2026-04-21 04:08:09.060538	1	1	\N	\N	1
576	3223.79	2035-09-01	2035-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.062877	2026-04-21 04:08:09.062877	1	1	\N	\N	1
577	3223.79	2035-10-01	2035-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.066701	2026-04-21 04:08:09.066701	1	1	\N	\N	1
578	3223.79	2035-11-01	2035-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.069216	2026-04-21 04:08:09.069216	1	1	\N	\N	1
579	3223.79	2035-12-01	2035-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.072418	2026-04-21 04:08:09.072418	1	1	\N	\N	1
580	3223.79	2036-01-01	2036-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.074682	2026-04-21 04:08:09.074682	1	1	\N	\N	1
581	3223.79	2036-02-01	2036-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.078129	2026-04-21 04:08:09.078129	1	1	\N	\N	1
582	3223.79	2036-03-01	2036-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.080434	2026-04-21 04:08:09.080434	1	1	\N	\N	1
583	3223.79	2036-04-01	2036-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.082564	2026-04-21 04:08:09.082564	1	1	\N	\N	1
584	3223.79	2036-05-01	2036-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.085104	2026-04-21 04:08:09.085104	1	1	\N	\N	1
585	3223.79	2036-06-01	2036-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.087786	2026-04-21 04:08:09.087786	1	1	\N	\N	1
586	3223.79	2036-07-01	2036-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.089863	2026-04-21 04:08:09.089863	1	1	\N	\N	1
587	3223.79	2036-08-01	2036-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.091929	2026-04-21 04:08:09.091929	1	1	\N	\N	1
588	3223.79	2036-09-01	2036-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.095088	2026-04-21 04:08:09.095088	1	1	\N	\N	1
589	3223.79	2036-10-01	2036-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.097305	2026-04-21 04:08:09.097305	1	1	\N	\N	1
590	3223.79	2036-11-01	2036-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.099363	2026-04-21 04:08:09.099363	1	1	\N	\N	1
591	3223.79	2036-12-01	2036-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.101432	2026-04-21 04:08:09.101432	1	1	\N	\N	1
592	1612.94	2026-05-01	2026-05-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:09.10451	2026-04-30 11:27:54.690903	1	1	\N	\N	1
596	1612.94	2026-09-01	2026-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.114012	2026-04-21 04:08:09.114012	1	1	\N	\N	1
597	1612.94	2026-10-01	2026-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.115975	2026-04-21 04:08:09.115975	1	1	\N	\N	1
598	1612.94	2026-11-01	2026-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.118053	2026-04-21 04:08:09.118053	1	1	\N	\N	1
599	1612.94	2026-12-01	2026-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.120144	2026-04-21 04:08:09.120144	1	1	\N	\N	1
600	1612.94	2027-01-01	2027-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.123014	2026-04-21 04:08:09.123014	1	1	\N	\N	1
601	1612.94	2027-02-01	2027-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.125171	2026-04-21 04:08:09.125171	1	1	\N	\N	1
602	1612.94	2027-03-01	2027-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.127578	2026-04-21 04:08:09.127578	1	1	\N	\N	1
603	1612.94	2027-04-01	2027-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.12976	2026-04-21 04:08:09.12976	1	1	\N	\N	1
604	1612.94	2027-05-01	2027-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.131675	2026-04-21 04:08:09.131675	1	1	\N	\N	1
605	1612.94	2027-06-01	2027-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.133654	2026-04-21 04:08:09.133654	1	1	\N	\N	1
606	1612.94	2027-07-01	2027-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.135649	2026-04-21 04:08:09.135649	1	1	\N	\N	1
607	1612.94	2027-08-01	2027-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.138052	2026-04-21 04:08:09.138052	1	1	\N	\N	1
608	1612.94	2027-09-01	2027-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.140152	2026-04-21 04:08:09.140152	1	1	\N	\N	1
609	1612.94	2027-10-01	2027-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.1423	2026-04-21 04:08:09.1423	1	1	\N	\N	1
610	1612.94	2027-11-01	2027-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.144909	2026-04-21 04:08:09.144909	1	1	\N	\N	1
611	1612.94	2027-12-01	2027-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.147062	2026-04-21 04:08:09.147062	1	1	\N	\N	1
612	1612.94	2028-01-01	2028-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.149055	2026-04-21 04:08:09.149055	1	1	\N	\N	1
613	1612.94	2028-02-01	2028-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.152373	2026-04-21 04:08:09.152373	1	1	\N	\N	1
614	1612.94	2028-03-01	2028-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.155184	2026-04-21 04:08:09.155184	1	1	\N	\N	1
615	1612.94	2028-04-01	2028-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.157379	2026-04-21 04:08:09.157379	1	1	\N	\N	1
616	1612.94	2028-05-01	2028-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.159746	2026-04-21 04:08:09.159746	1	1	\N	\N	1
617	1612.94	2028-06-01	2028-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.163227	2026-04-21 04:08:09.163227	1	1	\N	\N	1
618	1612.94	2028-07-01	2028-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.165808	2026-04-21 04:08:09.165808	1	1	\N	\N	1
619	1612.94	2028-08-01	2028-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.167991	2026-04-21 04:08:09.167991	1	1	\N	\N	1
620	1612.94	2028-09-01	2028-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.171803	2026-04-21 04:08:09.171803	1	1	\N	\N	1
621	1612.94	2028-10-01	2028-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.177248	2026-04-21 04:08:09.177248	1	1	\N	\N	1
622	1612.94	2028-11-01	2028-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.181752	2026-04-21 04:08:09.181752	1	1	\N	\N	1
1485	128.26	2026-06-28	2026-06-28	Tatico	11	\N	0	t	2026-06-29 19:55:36.621641	2026-07-02 00:13:18.245009	1	1	\N	2026-07-02 00:13:18.243851	1
595	1612.94	2026-08-01	2026-08-01	Sicoob Consignado	30	\N	1	t	2026-04-21 04:08:09.111773	2026-08-04 13:26:44.818691	1	1	\N	2026-08-04 13:26:44.818623	1
623	1612.94	2028-12-01	2028-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.18566	2026-04-21 04:08:09.18566	1	1	\N	\N	1
624	1612.94	2029-01-01	2029-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.189999	2026-04-21 04:08:09.189999	1	1	\N	\N	1
625	1612.94	2029-02-01	2029-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.192754	2026-04-21 04:08:09.192754	1	1	\N	\N	1
626	1612.94	2029-03-01	2029-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.196441	2026-04-21 04:08:09.196441	1	1	\N	\N	1
627	1612.94	2029-04-01	2029-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.198774	2026-04-21 04:08:09.198774	1	1	\N	\N	1
628	1612.94	2029-05-01	2029-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.201429	2026-04-21 04:08:09.201429	1	1	\N	\N	1
629	1612.94	2029-06-01	2029-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.203704	2026-04-21 04:08:09.203704	1	1	\N	\N	1
630	1612.94	2029-07-01	2029-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.206344	2026-04-21 04:08:09.206344	1	1	\N	\N	1
631	1612.94	2029-08-01	2029-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.209247	2026-04-21 04:08:09.209247	1	1	\N	\N	1
632	1612.94	2029-09-01	2029-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.213233	2026-04-21 04:08:09.213233	1	1	\N	\N	1
633	1612.94	2029-10-01	2029-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.215633	2026-04-21 04:08:09.215633	1	1	\N	\N	1
634	1612.94	2029-11-01	2029-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.217705	2026-04-21 04:08:09.217705	1	1	\N	\N	1
635	1612.94	2029-12-01	2029-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.221631	2026-04-21 04:08:09.221631	1	1	\N	\N	1
636	1612.94	2030-01-01	2030-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.224966	2026-04-21 04:08:09.224966	1	1	\N	\N	1
637	1612.94	2030-02-01	2030-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.229531	2026-04-21 04:08:09.229531	1	1	\N	\N	1
638	1612.94	2030-03-01	2030-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.232294	2026-04-21 04:08:09.232294	1	1	\N	\N	1
639	1612.94	2030-04-01	2030-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.234586	2026-04-21 04:08:09.234586	1	1	\N	\N	1
640	1612.94	2030-05-01	2030-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.236726	2026-04-21 04:08:09.236726	1	1	\N	\N	1
641	1612.94	2030-06-01	2030-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.239248	2026-04-21 04:08:09.239248	1	1	\N	\N	1
642	1612.94	2030-07-01	2030-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.241667	2026-04-21 04:08:09.241667	1	1	\N	\N	1
643	1612.94	2030-08-01	2030-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.245086	2026-04-21 04:08:09.245086	1	1	\N	\N	1
644	1612.94	2030-09-01	2030-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.247956	2026-04-21 04:08:09.247956	1	1	\N	\N	1
645	1612.94	2030-10-01	2030-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.250148	2026-04-21 04:08:09.250148	1	1	\N	\N	1
646	1612.94	2030-11-01	2030-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.252161	2026-04-21 04:08:09.252161	1	1	\N	\N	1
647	1612.94	2030-12-01	2030-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.254387	2026-04-21 04:08:09.254387	1	1	\N	\N	1
648	1612.94	2031-01-01	2031-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.257054	2026-04-21 04:08:09.257054	1	1	\N	\N	1
649	1612.94	2031-02-01	2031-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.262833	2026-04-21 04:08:09.262833	1	1	\N	\N	1
650	1612.94	2031-03-01	2031-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.266007	2026-04-21 04:08:09.266007	1	1	\N	\N	1
651	1612.94	2031-04-01	2031-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.268143	2026-04-21 04:08:09.268143	1	1	\N	\N	1
652	1612.94	2031-05-01	2031-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.270368	2026-04-21 04:08:09.270368	1	1	\N	\N	1
653	1612.94	2031-06-01	2031-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.273988	2026-04-21 04:08:09.273988	1	1	\N	\N	1
654	1612.94	2031-07-01	2031-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.277622	2026-04-21 04:08:09.277622	1	1	\N	\N	1
655	1612.94	2031-08-01	2031-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.280993	2026-04-21 04:08:09.280993	1	1	\N	\N	1
656	1612.94	2031-09-01	2031-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.283222	2026-04-21 04:08:09.283222	1	1	\N	\N	1
657	1612.94	2031-10-01	2031-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.285991	2026-04-21 04:08:09.285991	1	1	\N	\N	1
658	1612.94	2031-11-01	2031-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.28825	2026-04-21 04:08:09.28825	1	1	\N	\N	1
659	1612.94	2031-12-01	2031-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.29104	2026-04-21 04:08:09.29104	1	1	\N	\N	1
660	1612.94	2032-01-01	2032-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.294709	2026-04-21 04:08:09.294709	1	1	\N	\N	1
661	1612.94	2032-02-01	2032-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.298215	2026-04-21 04:08:09.298215	1	1	\N	\N	1
662	1612.94	2032-03-01	2032-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.300359	2026-04-21 04:08:09.300359	1	1	\N	\N	1
663	1612.94	2032-04-01	2032-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.302331	2026-04-21 04:08:09.302331	1	1	\N	\N	1
664	1612.94	2032-05-01	2032-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.305348	2026-04-21 04:08:09.305348	1	1	\N	\N	1
665	1612.94	2032-06-01	2032-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.30811	2026-04-21 04:08:09.30811	1	1	\N	\N	1
666	1612.94	2032-07-01	2032-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.311445	2026-04-21 04:08:09.311445	1	1	\N	\N	1
667	1612.94	2032-08-01	2032-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.315103	2026-04-21 04:08:09.315103	1	1	\N	\N	1
668	1612.94	2032-09-01	2032-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.317219	2026-04-21 04:08:09.317219	1	1	\N	\N	1
669	1612.94	2032-10-01	2032-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.319158	2026-04-21 04:08:09.319158	1	1	\N	\N	1
670	1612.94	2032-11-01	2032-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.321357	2026-04-21 04:08:09.321357	1	1	\N	\N	1
671	1612.94	2032-12-01	2032-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.323947	2026-04-21 04:08:09.323947	1	1	\N	\N	1
672	1612.94	2033-01-01	2033-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.327632	2026-04-21 04:08:09.327632	1	1	\N	\N	1
673	1612.94	2033-02-01	2033-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.331013	2026-04-21 04:08:09.331013	1	1	\N	\N	1
674	1612.94	2033-03-01	2033-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.333125	2026-04-21 04:08:09.333125	1	1	\N	\N	1
675	1612.94	2033-04-01	2033-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.335159	2026-04-21 04:08:09.335159	1	1	\N	\N	1
676	1612.94	2033-05-01	2033-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.337176	2026-04-21 04:08:09.337176	1	1	\N	\N	1
677	1612.94	2033-06-01	2033-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.339536	2026-04-21 04:08:09.339536	1	1	\N	\N	1
678	1612.94	2033-07-01	2033-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.342118	2026-04-21 04:08:09.342118	1	1	\N	\N	1
679	1612.94	2033-08-01	2033-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.345608	2026-04-21 04:08:09.345608	1	1	\N	\N	1
680	1612.94	2033-09-01	2033-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.348453	2026-04-21 04:08:09.348453	1	1	\N	\N	1
681	1612.94	2033-10-01	2033-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.350563	2026-04-21 04:08:09.350563	1	1	\N	\N	1
682	1612.94	2033-11-01	2033-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.352661	2026-04-21 04:08:09.352661	1	1	\N	\N	1
683	1612.94	2033-12-01	2033-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.354871	2026-04-21 04:08:09.354871	1	1	\N	\N	1
684	1612.94	2034-01-01	2034-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.358991	2026-04-21 04:08:09.358991	1	1	\N	\N	1
685	1612.94	2034-02-01	2034-02-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.363677	2026-04-21 04:08:09.363677	1	1	\N	\N	1
686	1612.94	2034-03-01	2034-03-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.366203	2026-04-21 04:08:09.366203	1	1	\N	\N	1
687	1612.94	2034-04-01	2034-04-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.368423	2026-04-21 04:08:09.368423	1	1	\N	\N	1
688	1612.94	2034-05-01	2034-05-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.371273	2026-04-21 04:08:09.371273	1	1	\N	\N	1
689	1612.94	2034-06-01	2034-06-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.373959	2026-04-21 04:08:09.373959	1	1	\N	\N	1
690	1612.94	2034-07-01	2034-07-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.376526	2026-04-21 04:08:09.376526	1	1	\N	\N	1
691	1612.94	2034-08-01	2034-08-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.380313	2026-04-21 04:08:09.380313	1	1	\N	\N	1
692	1612.94	2034-09-01	2034-09-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.383339	2026-04-21 04:08:09.383339	1	1	\N	\N	1
693	1612.94	2034-10-01	2034-10-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.385702	2026-04-21 04:08:09.385702	1	1	\N	\N	1
694	1612.94	2034-11-01	2034-11-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.388023	2026-04-21 04:08:09.388023	1	1	\N	\N	1
695	1612.94	2034-12-01	2034-12-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.391105	2026-04-21 04:08:09.391105	1	1	\N	\N	1
696	1612.94	2035-01-01	2035-01-01	Sicoob Consignado	30	\N	1	f	2026-04-21 04:08:09.394229	2026-04-21 04:08:09.394229	1	1	\N	\N	1
719	233	2026-06-01	2026-06-01	Alfa Consignado	30	\N	1	t	2026-04-21 04:08:09.457779	2026-05-29 11:12:23.048578	1	1	\N	2026-05-29 11:12:23.048522	1
701	725.33	2026-09-05	2026-09-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.407813	2026-04-21 04:08:09.407813	1	1	\N	\N	1
702	725.33	2026-10-05	2026-10-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.410924	2026-04-21 04:08:09.410924	1	1	\N	\N	1
703	725.33	2026-11-05	2026-11-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.414693	2026-04-21 04:08:09.414693	1	1	\N	\N	1
704	725.33	2026-12-05	2026-12-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.416853	2026-04-21 04:08:09.416853	1	1	\N	\N	1
705	725.33	2027-01-05	2027-01-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.419021	2026-04-21 04:08:09.419021	1	1	\N	\N	1
706	725.33	2027-02-05	2027-02-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.421819	2026-04-21 04:08:09.421819	1	1	\N	\N	1
707	725.33	2027-03-05	2027-03-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.424759	2026-04-21 04:08:09.424759	1	1	\N	\N	1
708	725.33	2027-04-05	2027-04-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.427711	2026-04-21 04:08:09.427711	1	1	\N	\N	1
709	725.33	2027-05-05	2027-05-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.43126	2026-04-21 04:08:09.43126	1	1	\N	\N	1
710	725.33	2027-06-05	2027-06-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.43347	2026-04-21 04:08:09.43347	1	1	\N	\N	1
711	725.33	2027-07-05	2027-07-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.435535	2026-04-21 04:08:09.435535	1	1	\N	\N	1
712	725.33	2027-08-05	2027-08-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.43774	2026-04-21 04:08:09.43774	1	1	\N	\N	1
713	725.33	2027-09-05	2027-09-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.440339	2026-04-21 04:08:09.440339	1	1	\N	\N	1
714	725.33	2027-10-05	2027-10-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.442853	2026-04-21 04:08:09.442853	1	1	\N	\N	1
715	725.33	2027-11-05	2027-11-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.446595	2026-04-21 04:08:09.446595	1	1	\N	\N	1
716	725.33	2027-12-05	2027-12-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.449472	2026-04-21 04:08:09.449472	1	1	\N	\N	1
717	725.33	2028-01-05	2028-01-05	Sicoob Emprestimo	30	\N	1	f	2026-04-21 04:08:09.451683	2026-04-21 04:08:09.451683	1	1	\N	\N	1
718	233	2026-05-01	2026-05-01	Alfa Consignado	30	\N	1	t	2026-04-21 04:08:09.453793	2026-04-30 13:43:09.550458	1	1	\N	2026-04-30 13:43:09.550392	1
698	725.33	2026-06-05	2026-06-05	Sicoob Emprestimo	30	\N	1	t	2026-04-21 04:08:09.400355	2026-06-02 22:15:25.98741	1	1	\N	2026-06-02 22:15:25.987348	1
722	233	2026-09-01	2026-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.467389	2026-04-21 04:08:09.467389	1	1	\N	\N	1
723	233	2026-10-01	2026-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.470202	2026-04-21 04:08:09.470202	1	1	\N	\N	1
724	233	2026-11-01	2026-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.472547	2026-04-21 04:08:09.472547	1	1	\N	\N	1
725	233	2026-12-01	2026-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.475198	2026-04-21 04:08:09.475198	1	1	\N	\N	1
726	233	2027-01-01	2027-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.479066	2026-04-21 04:08:09.479066	1	1	\N	\N	1
727	233	2027-02-01	2027-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.481699	2026-04-21 04:08:09.481699	1	1	\N	\N	1
728	233	2027-03-01	2027-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.483771	2026-04-21 04:08:09.483771	1	1	\N	\N	1
729	233	2027-04-01	2027-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.485766	2026-04-21 04:08:09.485766	1	1	\N	\N	1
730	233	2027-05-01	2027-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.488368	2026-04-21 04:08:09.488368	1	1	\N	\N	1
731	233	2027-06-01	2027-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.490818	2026-04-21 04:08:09.490818	1	1	\N	\N	1
732	233	2027-07-01	2027-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.492933	2026-04-21 04:08:09.492933	1	1	\N	\N	1
733	233	2027-08-01	2027-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.496324	2026-04-21 04:08:09.496324	1	1	\N	\N	1
734	233	2027-09-01	2027-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.499798	2026-04-21 04:08:09.499798	1	1	\N	\N	1
735	233	2027-10-01	2027-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.501904	2026-04-21 04:08:09.501904	1	1	\N	\N	1
736	233	2027-11-01	2027-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.503831	2026-04-21 04:08:09.503831	1	1	\N	\N	1
737	233	2027-12-01	2027-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.506581	2026-04-21 04:08:09.506581	1	1	\N	\N	1
738	233	2028-01-01	2028-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.509501	2026-04-21 04:08:09.509501	1	1	\N	\N	1
739	233	2028-02-01	2028-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.514278	2026-04-21 04:08:09.514278	1	1	\N	\N	1
740	233	2028-03-01	2028-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.516897	2026-04-21 04:08:09.516897	1	1	\N	\N	1
741	233	2028-04-01	2028-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.519103	2026-04-21 04:08:09.519103	1	1	\N	\N	1
742	233	2028-05-01	2028-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.521101	2026-04-21 04:08:09.521101	1	1	\N	\N	1
743	233	2028-06-01	2028-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.523502	2026-04-21 04:08:09.523502	1	1	\N	\N	1
744	233	2028-07-01	2028-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.526088	2026-04-21 04:08:09.526088	1	1	\N	\N	1
745	233	2028-08-01	2028-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.529574	2026-04-21 04:08:09.529574	1	1	\N	\N	1
746	233	2028-09-01	2028-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.532571	2026-04-21 04:08:09.532571	1	1	\N	\N	1
720	233	2026-07-01	2026-07-01	Alfa Consignado	30	\N	1	t	2026-04-21 04:08:09.461338	2026-06-29 20:05:53.776627	1	1	\N	2026-06-29 20:05:53.776559	1
699	725.33	2026-07-05	2026-07-05	Sicoob Emprestimo	30	\N	1	t	2026-04-21 04:08:09.402901	2026-07-02 00:25:15.982535	1	1	\N	2026-07-02 00:25:15.982464	1
721	233	2026-08-01	2026-08-01	Alfa Consignado	30	\N	1	t	2026-04-21 04:08:09.465055	2026-08-04 13:26:30.805821	1	1	\N	2026-08-04 13:26:30.80575	1
700	725.33	2026-08-05	2026-08-05	Sicoob Emprestimo	30	\N	1	t	2026-04-21 04:08:09.405336	2026-08-04 13:38:17.08492	1	1	\N	2026-08-04 13:38:17.084811	1
748	233	2028-11-01	2028-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.536685	2026-04-21 04:08:09.536685	1	1	\N	\N	1
749	233	2028-12-01	2028-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.538917	2026-04-21 04:08:09.538917	1	1	\N	\N	1
750	233	2029-01-01	2029-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.541349	2026-04-21 04:08:09.541349	1	1	\N	\N	1
751	233	2029-02-01	2029-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.544138	2026-04-21 04:08:09.544138	1	1	\N	\N	1
752	233	2029-03-01	2029-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.547708	2026-04-21 04:08:09.547708	1	1	\N	\N	1
753	233	2029-04-01	2029-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.550012	2026-04-21 04:08:09.550012	1	1	\N	\N	1
754	233	2029-05-01	2029-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.553627	2026-04-21 04:08:09.553627	1	1	\N	\N	1
755	233	2029-06-01	2029-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.555748	2026-04-21 04:08:09.555748	1	1	\N	\N	1
756	233	2029-07-01	2029-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.55811	2026-04-21 04:08:09.55811	1	1	\N	\N	1
757	233	2029-08-01	2029-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.56198	2026-04-21 04:08:09.56198	1	1	\N	\N	1
758	233	2029-09-01	2029-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.56568	2026-04-21 04:08:09.56568	1	1	\N	\N	1
759	233	2029-10-01	2029-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.568057	2026-04-21 04:08:09.568057	1	1	\N	\N	1
760	233	2029-11-01	2029-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.570674	2026-04-21 04:08:09.570674	1	1	\N	\N	1
761	233	2029-12-01	2029-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.573739	2026-04-21 04:08:09.573739	1	1	\N	\N	1
762	233	2030-01-01	2030-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.576701	2026-04-21 04:08:09.576701	1	1	\N	\N	1
763	233	2030-02-01	2030-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.58027	2026-04-21 04:08:09.58027	1	1	\N	\N	1
764	233	2030-03-01	2030-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.583087	2026-04-21 04:08:09.583087	1	1	\N	\N	1
765	233	2030-04-01	2030-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.585884	2026-04-21 04:08:09.585884	1	1	\N	\N	1
766	233	2030-05-01	2030-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.587953	2026-04-21 04:08:09.587953	1	1	\N	\N	1
767	233	2030-06-01	2030-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.590273	2026-04-21 04:08:09.590273	1	1	\N	\N	1
768	233	2030-07-01	2030-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.593517	2026-04-21 04:08:09.593517	1	1	\N	\N	1
769	233	2030-08-01	2030-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.597492	2026-04-21 04:08:09.597492	1	1	\N	\N	1
770	233	2030-09-01	2030-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.600002	2026-04-21 04:08:09.600002	1	1	\N	\N	1
771	233	2030-10-01	2030-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.602278	2026-04-21 04:08:09.602278	1	1	\N	\N	1
772	233	2030-11-01	2030-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.604711	2026-04-21 04:08:09.604711	1	1	\N	\N	1
773	233	2030-12-01	2030-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.607674	2026-04-21 04:08:09.607674	1	1	\N	\N	1
774	233	2031-01-01	2031-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.610571	2026-04-21 04:08:09.610571	1	1	\N	\N	1
775	233	2031-02-01	2031-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.614309	2026-04-21 04:08:09.614309	1	1	\N	\N	1
776	233	2031-03-01	2031-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.616569	2026-04-21 04:08:09.616569	1	1	\N	\N	1
777	233	2031-04-01	2031-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.618642	2026-04-21 04:08:09.618642	1	1	\N	\N	1
778	233	2031-05-01	2031-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.620572	2026-04-21 04:08:09.620572	1	1	\N	\N	1
779	233	2031-06-01	2031-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.622588	2026-04-21 04:08:09.622588	1	1	\N	\N	1
780	233	2031-07-01	2031-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.625066	2026-04-21 04:08:09.625066	1	1	\N	\N	1
781	233	2031-08-01	2031-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.627486	2026-04-21 04:08:09.627486	1	1	\N	\N	1
782	233	2031-09-01	2031-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.631119	2026-04-21 04:08:09.631119	1	1	\N	\N	1
783	233	2031-10-01	2031-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.633451	2026-04-21 04:08:09.633451	1	1	\N	\N	1
784	233	2031-11-01	2031-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.635555	2026-04-21 04:08:09.635555	1	1	\N	\N	1
785	233	2031-12-01	2031-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.637493	2026-04-21 04:08:09.637493	1	1	\N	\N	1
786	233	2032-01-01	2032-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.639514	2026-04-21 04:08:09.639514	1	1	\N	\N	1
787	233	2032-02-01	2032-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.643374	2026-04-21 04:08:09.643374	1	1	\N	\N	1
788	233	2032-03-01	2032-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.647261	2026-04-21 04:08:09.647261	1	1	\N	\N	1
789	233	2032-04-01	2032-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.650041	2026-04-21 04:08:09.650041	1	1	\N	\N	1
790	233	2032-05-01	2032-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.652353	2026-04-21 04:08:09.652353	1	1	\N	\N	1
791	233	2032-06-01	2032-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.655393	2026-04-21 04:08:09.655393	1	1	\N	\N	1
792	233	2032-07-01	2032-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.657884	2026-04-21 04:08:09.657884	1	1	\N	\N	1
793	233	2032-08-01	2032-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.660382	2026-04-21 04:08:09.660382	1	1	\N	\N	1
794	233	2032-09-01	2032-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.664112	2026-04-21 04:08:09.664112	1	1	\N	\N	1
795	233	2032-10-01	2032-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.667324	2026-04-21 04:08:09.667324	1	1	\N	\N	1
796	233	2032-11-01	2032-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.669418	2026-04-21 04:08:09.669418	1	1	\N	\N	1
797	233	2032-12-01	2032-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.671383	2026-04-21 04:08:09.671383	1	1	\N	\N	1
798	233	2033-01-01	2033-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.673932	2026-04-21 04:08:09.673932	1	1	\N	\N	1
799	233	2033-02-01	2033-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.676497	2026-04-21 04:08:09.676497	1	1	\N	\N	1
800	233	2033-03-01	2033-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.680229	2026-04-21 04:08:09.680229	1	1	\N	\N	1
801	233	2033-04-01	2033-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.683383	2026-04-21 04:08:09.683383	1	1	\N	\N	1
802	233	2033-05-01	2033-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.686085	2026-04-21 04:08:09.686085	1	1	\N	\N	1
803	233	2033-06-01	2033-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.688372	2026-04-21 04:08:09.688372	1	1	\N	\N	1
804	233	2033-07-01	2033-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.690718	2026-04-21 04:08:09.690718	1	1	\N	\N	1
805	233	2033-08-01	2033-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.694528	2026-04-21 04:08:09.694528	1	1	\N	\N	1
806	233	2033-09-01	2033-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.698733	2026-04-21 04:08:09.698733	1	1	\N	\N	1
807	233	2033-10-01	2033-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.702057	2026-04-21 04:08:09.702057	1	1	\N	\N	1
808	233	2033-11-01	2033-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.704371	2026-04-21 04:08:09.704371	1	1	\N	\N	1
809	233	2033-12-01	2033-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.706652	2026-04-21 04:08:09.706652	1	1	\N	\N	1
810	233	2034-01-01	2034-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.709182	2026-04-21 04:08:09.709182	1	1	\N	\N	1
811	233	2034-02-01	2034-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.712294	2026-04-21 04:08:09.712294	1	1	\N	\N	1
812	233	2034-03-01	2034-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.716348	2026-04-21 04:08:09.716348	1	1	\N	\N	1
813	233	2034-04-01	2034-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.718699	2026-04-21 04:08:09.718699	1	1	\N	\N	1
814	233	2034-05-01	2034-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.720718	2026-04-21 04:08:09.720718	1	1	\N	\N	1
815	233	2034-06-01	2034-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.722791	2026-04-21 04:08:09.722791	1	1	\N	\N	1
816	233	2034-07-01	2034-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.72511	2026-04-21 04:08:09.72511	1	1	\N	\N	1
817	233	2034-08-01	2034-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.728635	2026-04-21 04:08:09.728635	1	1	\N	\N	1
818	233	2034-09-01	2034-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.736405	2026-04-21 04:08:09.736405	1	1	\N	\N	1
819	233	2034-10-01	2034-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.740709	2026-04-21 04:08:09.740709	1	1	\N	\N	1
820	233	2034-11-01	2034-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.745966	2026-04-21 04:08:09.745966	1	1	\N	\N	1
821	233	2034-12-01	2034-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.753116	2026-04-21 04:08:09.753116	1	1	\N	\N	1
822	233	2035-01-01	2035-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.757092	2026-04-21 04:08:09.757092	1	1	\N	\N	1
823	233	2035-02-01	2035-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.761345	2026-04-21 04:08:09.761345	1	1	\N	\N	1
824	233	2035-03-01	2035-03-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.766148	2026-04-21 04:08:09.766148	1	1	\N	\N	1
825	233	2035-04-01	2035-04-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.771758	2026-04-21 04:08:09.771758	1	1	\N	\N	1
826	233	2035-05-01	2035-05-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.77535	2026-04-21 04:08:09.77535	1	1	\N	\N	1
827	233	2035-06-01	2035-06-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.778462	2026-04-21 04:08:09.778462	1	1	\N	\N	1
828	233	2035-07-01	2035-07-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.782887	2026-04-21 04:08:09.782887	1	1	\N	\N	1
829	233	2035-08-01	2035-08-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.78536	2026-04-21 04:08:09.78536	1	1	\N	\N	1
830	233	2035-09-01	2035-09-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.787477	2026-04-21 04:08:09.787477	1	1	\N	\N	1
831	233	2035-10-01	2035-10-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.789601	2026-04-21 04:08:09.789601	1	1	\N	\N	1
832	233	2035-11-01	2035-11-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.793024	2026-04-21 04:08:09.793024	1	1	\N	\N	1
833	233	2035-12-01	2035-12-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.796718	2026-04-21 04:08:09.796718	1	1	\N	\N	1
834	233	2036-01-01	2036-01-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.80012	2026-04-21 04:08:09.80012	1	1	\N	\N	1
835	233	2036-02-01	2036-02-01	Alfa Consignado	30	\N	1	f	2026-04-21 04:08:09.802812	2026-04-21 04:08:09.802812	1	1	\N	\N	1
939	187.44	2026-04-29	2026-06-05	Mercado Tatico	11	7	2	t	2026-04-30 10:53:28.05551	2026-05-29 11:11:19.613227	1	1	\N	2026-05-29 11:11:19.613171	1
841	1600	2026-10-01	2026-10-01	Previsão de Gastos	53	\N	0	f	2026-04-21 04:22:58.084241	2026-04-21 04:22:58.084241	1	1	\N	\N	1
842	1600	2026-11-01	2026-11-01	Previsão de Gastos	53	\N	0	f	2026-04-21 04:22:58.086553	2026-04-21 04:22:58.086553	1	1	\N	\N	1
843	300	2026-01-27	2026-05-08	Pix no crédito	30	8	3	t	2026-04-21 04:28:18.060073	2026-04-30 13:49:57.044182	12	4	843	2026-04-30 13:49:57.044105	1
1058	158.8	2026-05-10	2026-06-04	Meli plus	48	5	2	t	2026-05-11 02:07:58.755834	2026-05-31 17:50:09.070922	1	1	\N	2026-05-31 17:50:09.070834	1
847	300	2026-01-27	2026-09-08	Pix no crédito	30	8	3	f	2026-04-21 04:28:18.070236	2026-04-21 04:28:18.070236	12	8	843	\N	1
848	300	2026-01-27	2026-10-08	Pix no crédito	30	8	3	f	2026-04-21 04:28:18.07143	2026-04-21 04:28:18.07143	12	9	843	\N	1
849	300	2026-01-27	2026-11-08	Pix no crédito	30	8	3	f	2026-04-21 04:28:18.072628	2026-04-21 04:28:18.072628	12	10	843	\N	1
850	300	2026-01-27	2026-12-08	Pix no crédito	30	8	3	f	2026-04-21 04:28:18.073807	2026-04-21 04:28:18.073807	12	11	843	\N	1
851	300	2026-01-27	2027-01-08	Pix no crédito	30	8	3	f	2026-04-21 04:28:18.075736	2026-04-21 04:28:18.075736	12	12	843	\N	1
844	300	2026-01-27	2026-06-08	Pix no crédito	30	8	3	t	2026-04-21 04:28:18.065974	2026-06-02 16:47:11.994467	12	5	843	2026-06-02 16:47:11.994467	1
1433	189.47	2026-06-01	2026-07-05	Store	11	7	2	t	2026-06-14 21:12:56.300214	2026-06-29 19:58:50.621384	1	1	\N	2026-06-29 19:58:50.620521	1
1432	11.9	2026-06-10	2026-07-05	Amazon Music	48	7	2	t	2026-06-14 21:11:59.244465	2026-06-29 19:59:20.671474	1	1	\N	2026-06-29 19:59:20.671415	1
1431	3050.0	2026-06-15	2026-06-15	Mão de Obra Azulejista 2	54	\N	0	t	2026-06-14 21:08:47.884776	2026-06-18 13:14:22.09244	1	1	\N	2026-06-18 13:14:22.09224	1
936	53.9	2026-04-25	2026-05-05	YouTube Premium	48	9	2	t	2026-04-26 01:47:56.126026	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
938	33.73	2026-04-22	2026-05-05	Ifood	12	9	2	t	2026-04-26 01:47:56.131787	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
937	18.99	2026-04-25	2026-05-05	99 Food	12	9	2	t	2026-04-26 01:47:56.127693	2026-05-02 16:21:30.94344	1	1	\N	2026-05-02 16:21:30.94344	1
284	416.67	2026-01-09	2026-07-07	Pix no Crédito	30	6	3	t	2026-04-21 03:44:47.280987	2026-06-29 19:58:02.707649	12	6	282	2026-06-29 19:58:02.70757	1
845	300	2026-01-27	2026-07-08	Pix no crédito	30	8	3	t	2026-04-21 04:28:18.067415	2026-06-29 19:58:28.812493	12	6	843	2026-06-29 19:58:28.812435	1
1430	27.24	2026-06-14	2026-07-08	Salgados Ifood	12	8	2	t	2026-06-14 21:06:10.067039	2026-06-29 19:58:39.073524	1	1	\N	2026-06-29 19:58:39.073435	1
1429	10.98	2026-06-12	2026-07-08	Pizza 99	12	8	2	t	2026-06-14 21:06:09.952687	2026-06-29 19:58:40.85951	1	1	\N	2026-06-29 19:58:40.859435	1
1486	21.37	2026-06-26	2026-06-26	Pratiko	12	\N	0	t	2026-06-29 19:56:23.919044	2026-06-29 20:07:01.867598	1	1	\N	2026-06-29 20:07:01.867216	1
1487	48.76	2026-06-25	2026-06-25	99 food	12	\N	0	t	2026-06-29 19:57:02.24311	2026-07-02 00:13:16.353892	1	1	\N	2026-07-02 00:13:16.353708	1
1408	15.0	2026-06-08	2026-07-13	PolySan	54	11	2	t	2026-06-09 19:08:32.835809	2026-07-11 12:46:10.171007	1	1	\N	2026-07-11 12:46:10.171007	1
1409	139.0	2026-06-09	2026-07-13	Center Sul	54	11	2	t	2026-06-09 19:08:32.843817	2026-07-11 12:46:10.171007	1	1	\N	2026-07-11 12:46:10.171007	1
1517	125.0	2026-07-08	2026-09-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.101987	2026-07-11 12:56:47.101987	12	2	1516	\N	1
1215	800.0	2026-05-26	2026-05-26	Motor portão eletrônico 	54	\N	0	t	2026-05-26 18:49:54.756452	2026-05-26 18:51:00.338884	1	1	\N	2026-05-26 18:51:00.338047	1
1214	200.0	2026-05-26	2026-05-26	Tubos Elétricos 	54	\N	0	t	2026-05-26 18:49:54.658575	2026-05-26 18:51:01.637098	1	1	\N	2026-05-26 18:51:01.637024	1
1518	125.0	2026-07-08	2026-10-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.107188	2026-07-11 12:56:47.107188	12	3	1516	\N	1
1519	125.0	2026-07-08	2026-11-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.110519	2026-07-11 12:56:47.110519	12	4	1516	\N	1
1520	125.0	2026-07-08	2026-12-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.114329	2026-07-11 12:56:47.114329	12	5	1516	\N	1
1521	125.0	2026-07-08	2027-01-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.121461	2026-07-11 12:56:47.121461	12	6	1516	\N	1
1522	125.0	2026-07-08	2027-02-07	Pix no Crédito Sicoob	54	6	3	f	2026-07-11 12:56:47.194746	2026-07-11 12:56:47.194746	12	7	1516	\N	1
846	300	2026-01-27	2026-08-08	Pix no crédito	30	8	3	t	2026-04-21 04:28:18.068618	2026-08-04 13:20:24.419771	12	7	843	2026-08-04 13:20:24.419771	1
1516	125.0	2026-07-08	2026-08-07	Pix no Crédito Sicoob	54	6	3	t	2026-07-11 12:56:47.032453	2026-08-04 13:20:38.973086	12	1	1516	2026-08-04 13:20:38.973086	1
\.


--
-- Data for Name: financial_goal_resources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.financial_goal_resources (id, financial_goal_id, resource_type, description, amount, include_in_total, notes, created_at, updated_at, source_type, source_id) FROM stdin;
23	28	2	Sicoob - Restante: R$ 6.685,79	6685.79	t	\N	2026-04-26 01:51:18.851344	2026-04-26 01:51:18.851344	Card	6
24	28	2	Caixa - Restante: R$ 5.300,00	5300.00	t	\N	2026-04-26 01:51:18.852913	2026-04-26 01:51:18.852913	Card	8
25	29	2	PicPay - Restante: R$ 2.779,21	2779.21	t	\N	2026-04-26 01:52:41.507764	2026-04-26 01:52:41.507764	Card	9
26	29	2	Caixa - Restante: R$ 5.300,00	5300.00	t	\N	2026-04-26 01:52:41.5088	2026-04-26 01:52:41.5088	Card	8
27	29	2	Sicoob - Restante: R$ 6.685,79	6685.79	t	\N	2026-04-26 01:52:41.50977	2026-04-26 01:52:41.50977	Card	6
\.


--
-- Data for Name: financial_goals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.financial_goals (id, description, target_amount, due_date, status, priority, notes, created_at, updated_at, current_amount, category_id, user_id, color) FROM stdin;
29	Móveis Planejados da Cozinha e Sala	30000.00	2027-07-01	0	1		2026-04-26 01:52:41.506581	2026-05-07 22:14:20.596581	0.00	54	1	#DC2626
31	Pintura casa antiga	3000.00	2026-08-17	0	2		2026-05-10 23:45:01.889468	2026-05-10 23:46:11.212894	0.00	54	1	#7C3AED
28	Pintura da casa	20000.00	2027-03-01	0	1		2026-04-26 01:51:18.845017	2026-08-04 13:50:55.384849	0.00	54	1	#0891B2
\.


--
-- Data for Name: incomes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.incomes (id, amount, date, balance_month, description, paid, created_at, updated_at, category_id, user_id) FROM stdin;
63	195.0	2026-06-04	2026-06-04	Kotas	t	2026-06-04 12:58:47.427032	2026-06-04 12:58:47.427032	87	1
79	1314.3	2026-07-08	2026-07-08	Pix no Crédito Sicoob	t	2026-07-11 12:50:19.863409	2026-07-11 12:50:19.863409	54	1
20	550.0	2026-05-01	2026-05-01	Venda de SitPass	t	2026-04-20 16:10:06.990808	2026-05-29 10:50:57.436404	87	1
8	13500	2026-05-31	2026-06-01	Salário	t	2026-04-20 16:08:06.736193	2026-05-29 10:51:02.645326	52	1
52	2628.0	2026-05-28	2026-05-28	Pix no credito Sicoob	t	2026-05-29 10:54:52.624574	2026-05-29 10:54:52.624574	54	1
80	876.2	2026-07-08	2026-07-08	Pix no Crédito Caixa	t	2026-07-11 12:51:09.412606	2026-07-11 12:51:09.412606	54	1
35	2108.0	2026-05-29	2026-05-29	Restituição	t	2026-04-21 04:17:20.712538	2026-06-02 21:44:10.021437	87	1
78	876.2	2026-07-09	2026-07-09	Pix no Crédito Neon	t	2026-07-11 12:48:53.136522	2026-07-11 12:51:25.392176	54	1
6	13100	2026-04-30	2026-05-01	Salário	t	2026-04-20 15:52:41.265695	2026-04-30 11:24:41.125389	52	1
7	5273.41	2026-03-31	2026-04-01	Sobra do mês anterior	t	2026-04-20 16:06:30.36053	2026-04-21 18:22:11.504417	52	1
12	13500	2026-09-30	2026-10-01	Salário	f	2026-04-20 16:08:06.765848	2026-04-20 16:08:06.765848	52	1
13	13500	2026-10-31	2026-11-01	Salário	f	2026-04-20 16:08:06.774146	2026-04-20 16:08:06.774146	52	1
14	13500	2026-11-30	2026-12-01	Salário	f	2026-04-20 16:08:06.782109	2026-04-20 16:08:06.782109	52	1
16	13500	2027-01-31	2027-02-01	Salário	f	2026-04-20 16:08:06.798176	2026-04-20 16:08:06.798176	52	1
17	13500	2027-02-28	2027-03-01	Salário	f	2026-04-20 16:08:06.805442	2026-04-20 16:08:06.805442	52	1
18	13500	2027-03-31	2027-04-01	Salário	f	2026-04-20 16:08:06.812281	2026-04-20 16:08:06.812281	52	1
19	13500	2027-04-30	2027-05-01	Salário	f	2026-04-20 16:08:06.820337	2026-04-20 16:08:06.820337	52	1
68	444.0	2026-06-14	2026-06-14	Pix no Crédito Caixa	t	2026-06-14 21:37:15.098798	2026-06-14 21:38:39.505778	54	1
69	1450.0	2026-06-14	2026-06-14	Pix no Crédito Sicoob	t	2026-06-14 21:37:18.57791	2026-06-14 21:38:44.393017	54	1
75	444.0	2026-06-14	2026-06-14	Pix no Crédito Amazon	t	2026-06-14 21:38:02.94988	2026-06-14 21:38:49.218681	54	1
24	13900	2027-06-30	2027-06-30	Salário	f	2026-04-21 04:10:06.549108	2026-04-21 04:10:06.549108	52	1
25	13900	2027-07-31	2027-07-31	Salário	f	2026-04-21 04:10:06.557785	2026-04-21 04:10:06.557785	52	1
26	13900	2027-08-31	2027-08-31	Salário	f	2026-04-21 04:10:06.565954	2026-04-21 04:10:06.565954	52	1
27	13900	2027-09-30	2027-09-30	Salário	f	2026-04-21 04:10:06.574139	2026-04-21 04:10:06.574139	52	1
28	13900	2027-10-31	2027-10-31	Salário	f	2026-04-21 04:10:06.583041	2026-04-21 04:10:06.583041	52	1
76	30.0	2026-06-13	2026-06-13	Thyeres Jogo	t	2026-06-14 21:48:39.819888	2026-06-14 21:48:39.819888	24	1
37	4043.46	2026-12-01	2026-12-01	13 segunda parcela	f	2026-04-21 04:19:04.976624	2026-04-21 16:24:39.763314	52	1
38	9849.39	2026-05-08	2026-05-08	Consignado 	t	2026-05-08 20:55:13.123952	2026-05-08 20:55:58.884698	30	1
34	13900	2028-04-30	2028-05-01	Salário	f	2026-04-21 04:10:06.630824	2026-05-11 02:12:19.754631	52	1
33	13900	2028-03-31	2028-04-01	Salário	f	2026-04-21 04:10:06.622746	2026-05-11 02:12:36.38126	52	1
32	13900	2028-02-29	2028-03-01	Salário	f	2026-04-21 04:10:06.614397	2026-05-11 02:12:56.853545	52	1
31	13900	2028-01-31	2028-02-01	Salário	f	2026-04-21 04:10:06.6069	2026-05-11 02:13:14.692461	52	1
30	13900	2027-12-31	2028-01-01	Salário	f	2026-04-21 04:10:06.598756	2026-05-11 02:13:35.964119	52	1
29	13900	2027-11-30	2027-12-01	Salário	f	2026-04-21 04:10:06.591001	2026-05-11 02:13:56.658052	52	1
53	4475.5	2026-06-03	2026-06-03	Pix no crédito Sicoob	t	2026-05-29 18:54:26.359607	2026-06-03 18:12:17.370775	54	1
56	4447.5	2026-06-03	2026-06-03	Pix no crédito Caixa	t	2026-05-30 11:16:40.457404	2026-06-03 18:12:50.893169	54	1
15	21000.0	2026-12-31	2027-01-01	Salário e Férias	f	2026-04-20 16:08:06.789607	2026-07-11 17:16:16.054147	52	1
59	550.0	2026-06-03	2026-06-03	Venda do SitPass	t	2026-05-31 18:08:23.394965	2026-06-03 18:13:06.716399	87	1
57	2223.75	2026-06-03	2026-06-03	Pix no crédito Pic Pay	t	2026-05-30 11:17:18.817259	2026-06-03 18:13:49.322028	54	1
9	16100.0	2026-06-30	2026-07-01	Salário	t	2026-04-20 16:08:06.743034	2026-06-29 20:02:28.11149	52	1
11	16290.0	2026-08-31	2026-09-01	Salário	f	2026-04-20 16:08:06.757664	2026-07-07 23:47:26.502975	52	1
77	4000.0	2026-07-11	2026-07-11	Tharllys	t	2026-07-11 12:47:40.938693	2026-07-11 12:47:40.938693	87	1
48	316.0	2026-05-23	2026-05-23	Rateio Sicoob Juri	t	2026-05-23 17:23:00.191727	2026-05-23 17:23:00.191727	87	1
49	433.0	2026-05-23	2026-05-23	Rateio Sicoob Cred	t	2026-05-23 17:23:36.627401	2026-05-23 17:23:36.627401	87	1
61	550.0	2026-07-01	2026-07-01	Venda do SitPass	t	2026-06-02 23:14:19.682423	2026-07-28 18:28:40.062883	87	1
81	1000.0	2026-07-20	2026-07-20	Tharllys	t	2026-08-04 13:15:09.776146	2026-08-04 13:15:09.776146	\N	1
10	21820.0	2026-07-31	2026-08-01	Salário e 13	t	2026-04-20 16:08:06.75068	2026-08-04 13:27:38.842215	52	1
82	2000.0	2026-07-24	2026-07-24	Limite caixa	t	2026-08-04 13:30:04.361769	2026-08-04 13:30:04.361769	30	1
83	1690.05	2026-08-04	2026-08-04	Pix no Crédito Sicoob	t	2026-08-04 13:47:45.522749	2026-08-04 13:47:45.522749	30	1
84	889.5	2026-08-04	2026-08-04	Pix no Crédito Caixa	t	2026-08-04 13:48:17.528425	2026-08-04 13:48:17.528425	30	1
85	1900.0	2026-08-13	2026-08-13	Limite Caixa	t	2026-08-14 16:10:31.8178	2026-08-14 16:10:31.8178	28	1
65	6090.0	2026-09-30	2026-10-01	Substituição 	f	2026-06-09 19:19:30.169641	2026-08-19 12:43:59.83612	52	1
87	125.26	2026-08-15	2026-08-15	Cashback Pic Pay	t	2026-08-21 12:39:28.956231	2026-08-21 12:39:28.956231	87	1
88	900.0	2026-08-20	2026-08-20	Tharllys	t	2026-08-21 12:40:47.966414	2026-08-21 12:40:47.966414	87	1
\.


--
-- Data for Name: passkey_credentials; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.passkey_credentials (id, user_id, webauthn_id, public_key, sign_count, nickname, last_used_at, created_at, updated_at) FROM stdin;
1	1	tOOu6e_LLdBuOu0zM3czAw	pQECAyYgASFYIAfeXQiz01qv7WU7wJkxaXSDshJjw8hSSjgzm-4cDMLPIlggWuinaawM9-rWrqODLeJrSPTo1DHAhy7W8lb819ojnXk	0	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36	2026-04-22 18:01:42.255364	2026-04-22 16:10:52.167909	2026-04-22 18:01:42.256897
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version) FROM stdin;
20260430090000
20260421101500
20260421100000
20260421094500
20260421093000
20260421090000
20260420010000
20260419000000
20260417000000
20260416233000
20260416224500
20260416223000
20260416215500
20260416213000
20251008174957
20251008174939
20251008165308
20251008005718
20251005154950
20251005154908
20251005024442
20251004192149
20251004180256
20251004180247
20251004180158
20251004180023
20260430142000
20260430143000
20260501002526
20260501002545
20260501002548
20260501002552
20260501002555
20260506223000
20260507090000
20260507100000
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, password_digest, webauthn_id, created_at, updated_at, encrypted_password, remember_created_at) FROM stdin;
1	carlosmurilonovais@gmail.com	$2a$12$pgMI.zZDepOrJ/.WrR1HWOn.vReXCQfdtTDk0vO4I5mw6HZ1WFFYm	m_cRs4QbRugiM3gAk3I4M0qx3bA026kATDH6raP2_0UcmTG9v49hmYg2z44o96ZU5Z7We99OFMiw1t7y6xmtyg	2026-04-22 15:19:49.428999	2026-05-01 03:16:50.540808	$2a$12$4fd01P3UyiMIhcx8RTsDSe4o3hLMUGKv6SSPEu5HpwqSJVhFkIhx6	\N
\.


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 23, true);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 23, true);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 1, false);


--
-- Name: cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cards_id_seq', 12, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 87, true);


--
-- Name: expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.expenses_id_seq', 1624, true);


--
-- Name: financial_goal_resources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.financial_goal_resources_id_seq', 31, true);


--
-- Name: financial_goals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.financial_goals_id_seq', 32, true);


--
-- Name: incomes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.incomes_id_seq', 88, true);


--
-- Name: passkey_credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.passkey_credentials_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: financial_goal_resources financial_goal_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_goal_resources
    ADD CONSTRAINT financial_goal_resources_pkey PRIMARY KEY (id);


--
-- Name: financial_goals financial_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_goals
    ADD CONSTRAINT financial_goals_pkey PRIMARY KEY (id);


--
-- Name: incomes incomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incomes
    ADD CONSTRAINT incomes_pkey PRIMARY KEY (id);


--
-- Name: passkey_credentials passkey_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_credentials
    ADD CONSTRAINT passkey_credentials_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_cards_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_user_id ON public.cards USING btree (user_id);


--
-- Name: index_categories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_user_id ON public.categories USING btree (user_id);


--
-- Name: index_expenses_on_card_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_expenses_on_card_id ON public.expenses USING btree (card_id);


--
-- Name: index_expenses_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_expenses_on_category_id ON public.expenses USING btree (category_id);


--
-- Name: index_expenses_on_installment_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_expenses_on_installment_group_id ON public.expenses USING btree (installment_group_id);


--
-- Name: index_expenses_on_paid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_expenses_on_paid_at ON public.expenses USING btree (paid_at);


--
-- Name: index_expenses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_expenses_on_user_id ON public.expenses USING btree (user_id);


--
-- Name: index_financial_goal_resources_on_financial_goal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goal_resources_on_financial_goal_id ON public.financial_goal_resources USING btree (financial_goal_id);


--
-- Name: index_financial_goal_resources_on_resource_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goal_resources_on_resource_type ON public.financial_goal_resources USING btree (resource_type);


--
-- Name: index_financial_goal_resources_on_source_type_and_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goal_resources_on_source_type_and_source_id ON public.financial_goal_resources USING btree (source_type, source_id);


--
-- Name: index_financial_goals_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goals_on_category_id ON public.financial_goals USING btree (category_id);


--
-- Name: index_financial_goals_on_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goals_on_due_date ON public.financial_goals USING btree (due_date);


--
-- Name: index_financial_goals_on_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goals_on_priority ON public.financial_goals USING btree (priority);


--
-- Name: index_financial_goals_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goals_on_status ON public.financial_goals USING btree (status);


--
-- Name: index_financial_goals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_goals_on_user_id ON public.financial_goals USING btree (user_id);


--
-- Name: index_incomes_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incomes_on_category_id ON public.incomes USING btree (category_id);


--
-- Name: index_incomes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incomes_on_user_id ON public.incomes USING btree (user_id);


--
-- Name: index_passkey_credentials_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_passkey_credentials_on_user_id ON public.passkey_credentials USING btree (user_id);


--
-- Name: index_passkey_credentials_on_webauthn_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_passkey_credentials_on_webauthn_id ON public.passkey_credentials USING btree (webauthn_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_webauthn_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_webauthn_id ON public.users USING btree (webauthn_id);


--
-- Name: expenses fk_rails_06966d0da0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT fk_rails_06966d0da0 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: financial_goal_resources fk_rails_15c4072f29; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_goal_resources
    ADD CONSTRAINT fk_rails_15c4072f29 FOREIGN KEY (financial_goal_id) REFERENCES public.financial_goals(id);


--
-- Name: passkey_credentials fk_rails_225250860c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_credentials
    ADD CONSTRAINT fk_rails_225250860c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: cards fk_rails_8ef7749967; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_rails_8ef7749967 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: expenses fk_rails_9d826f8a58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT fk_rails_9d826f8a58 FOREIGN KEY (card_id) REFERENCES public.cards(id);


--
-- Name: financial_goals fk_rails_9d834367b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_goals
    ADD CONSTRAINT fk_rails_9d834367b2 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: incomes fk_rails_9e831c5cae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incomes
    ADD CONSTRAINT fk_rails_9e831c5cae FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: categories fk_rails_b8e2f7adfc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_b8e2f7adfc FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: expenses fk_rails_c3ee69df61; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT fk_rails_c3ee69df61 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: financial_goals fk_rails_cdd9c797dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_goals
    ADD CONSTRAINT fk_rails_cdd9c797dd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: incomes fk_rails_e53b3fa7c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incomes
    ADD CONSTRAINT fk_rails_e53b3fa7c7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.active_storage_attachments ENABLE ROW LEVEL SECURITY;

--
-- Name: active_storage_blobs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.active_storage_blobs ENABLE ROW LEVEL SECURITY;

--
-- Name: active_storage_variant_records; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.active_storage_variant_records ENABLE ROW LEVEL SECURITY;

--
-- Name: ar_internal_metadata; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ar_internal_metadata ENABLE ROW LEVEL SECURITY;

--
-- Name: cards; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;

--
-- Name: categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

--
-- Name: expenses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

--
-- Name: financial_goal_resources; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.financial_goal_resources ENABLE ROW LEVEL SECURITY;

--
-- Name: financial_goals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.financial_goals ENABLE ROW LEVEL SECURITY;

--
-- Name: incomes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.incomes ENABLE ROW LEVEL SECURITY;

--
-- Name: passkey_credentials; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.passkey_credentials ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict wV0Jx9eQDoR0PeOI8tCju42vyf4NE0QshZLW9jEgfMBQjEJO3vexYkKgISRgqKe

