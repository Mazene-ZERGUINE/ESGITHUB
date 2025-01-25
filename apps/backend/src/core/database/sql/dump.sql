--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Debian 16.2-1.pgdg120+2)
-- Dumped by pg_dump version 16.2 (Debian 16.2-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: psql
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO psql;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: psql
--

COMMENT ON SCHEMA public IS '';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: file_types_enum; Type: TYPE; Schema: public; Owner: psql
--

CREATE TYPE public.file_types_enum AS ENUM (
    'txt',
    'csv',
    'json',
    'xlsx',
    'yml'
);


ALTER TYPE public.file_types_enum OWNER TO psql;

--
-- Name: program_visibility_enum; Type: TYPE; Schema: public; Owner: psql
--

CREATE TYPE public.program_visibility_enum AS ENUM (
    'public',
    'private',
    'only_followers'
);


ALTER TYPE public.program_visibility_enum OWNER TO psql;

--
-- Name: programming_language_enum; Type: TYPE; Schema: public; Owner: psql
--

CREATE TYPE public.programming_language_enum AS ENUM (
    'python',
    'javascript'
);


ALTER TYPE public.programming_language_enum OWNER TO psql;

--
-- Name: reaction_entity_type_enum; Type: TYPE; Schema: public; Owner: psql
--

CREATE TYPE public.reaction_entity_type_enum AS ENUM (
    'like',
    'dislike'
);


ALTER TYPE public.reaction_entity_type_enum OWNER TO psql;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.comment (
    "commentId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    content text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "userId" uuid,
    "programId" uuid,
    "codeLineNumber" integer,
    "parentCommentId" uuid
);


ALTER TABLE public.comment OWNER TO psql;

--
-- Name: follow; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.follow (
    "relationId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "followerUserId" uuid,
    "followingUserId" uuid
);


ALTER TABLE public.follow OWNER TO psql;

--
-- Name: group; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public."group" (
    "groupId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(60) NOT NULL,
    description text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "ownerUserId" uuid NOT NULL,
    "imageUrl" text,
    visibility text DEFAULT 'public'::text
);


ALTER TABLE public."group" OWNER TO psql;

--
-- Name: group_programs; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.group_programs (
    "groupId" uuid NOT NULL,
    "programId" uuid NOT NULL
);


ALTER TABLE public.group_programs OWNER TO psql;

--
-- Name: program; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.program (
    "programId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description character varying(255),
    "programmingLanguage" character varying NOT NULL,
    "sourceCode" character varying NOT NULL,
    visibility character varying NOT NULL,
    "inputTypes" text,
    "outputTypes" text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "userUserId" uuid,
    "isProgramGroup" boolean DEFAULT false
);


ALTER TABLE public.program OWNER TO psql;

--
-- Name: program-version; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public."program-version" (
    "programVersionId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying DEFAULT '1.0.0'::character varying NOT NULL,
    "programmingLanguage" character varying NOT NULL,
    "sourceCode" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "programProgramId" uuid
);


ALTER TABLE public."program-version" OWNER TO psql;

--
-- Name: program-versions; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public."program-versions" (
    "programVersionId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying DEFAULT '1.0.0'::character varying NOT NULL,
    "programmingLanguage" character varying NOT NULL,
    "sourceCode" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "programProgramId" uuid
);


ALTER TABLE public."program-versions" OWNER TO psql;

--
-- Name: program_version_entity; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.program_version_entity (
    "programVersionId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying DEFAULT '1.0.0'::character varying NOT NULL,
    "programmingLanguage" character varying NOT NULL,
    "sourceCode" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "programProgramId" uuid
);


ALTER TABLE public.program_version_entity OWNER TO psql;

--
-- Name: reaction_entity; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.reaction_entity (
    "reactionId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type public.reaction_entity_type_enum NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "userId" uuid,
    "programId" uuid
);


ALTER TABLE public.reaction_entity OWNER TO psql;

--
-- Name: user; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public."user" (
    "userId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "userName" character varying(60) NOT NULL,
    "firstName" character varying(60) NOT NULL,
    "lastName" character varying(60) NOT NULL,
    email character varying(60) NOT NULL,
    password character varying(255) NOT NULL,
    "avatarUrl" character varying,
    bio character varying,
    "isVerified" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."user" OWNER TO psql;

--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.user_groups (
    "userId" uuid NOT NULL,
    "groupId" uuid NOT NULL
);


ALTER TABLE public.user_groups OWNER TO psql;

--
-- Name: users; Type: TABLE; Schema: public; Owner: psql
--

CREATE TABLE public.users (
    "userId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "userName" character varying(60) NOT NULL,
    "firstName" character varying(60) NOT NULL,
    "lastName" character varying(60) NOT NULL,
    email character varying(60) NOT NULL,
    password character varying(255) NOT NULL,
    "avatarUrl" character varying,
    bio character varying,
    "isVerified" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO psql;

--
-- Data for Name: comment; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.comment ("commentId", content, "createdAt", "updatedAt", "userId", "programId", "codeLineNumber", "parentCommentId") FROM stdin;
56a4c413-c3c9-4989-8862-a22ea9e85d9a	Really helpful, thanks!	2024-06-26 18:57:03.286025	2024-06-26 18:57:03.286025	c02fcc25-b9f3-4473-bf1a-80abbdc73474	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
92501e80-8d42-4d5e-b8e4-2a9bfec51f8b	Amazing content.	2024-06-26 18:57:03.298783	2024-06-26 18:57:03.298783	31c3d5b3-8c7c-4cef-a037-2eccb1839791	25ba8c0b-e206-475b-a899-ebf6ddb9f593	\N	\N
c311d639-7e95-4bca-ad58-c0b04748d0d7	Fantastic!	2024-06-26 18:57:03.301976	2024-06-26 18:57:03.301976	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	\N	\N
8dbed8bf-c0e8-4619-a603-556fcbc81894	Not what I expected.	2024-06-26 18:57:03.304202	2024-06-26 18:57:03.304202	4ac4c910-d783-48d5-ae41-b542e8cb666f	0f81f051-ed2a-4931-87bf-544c4f6fe647	\N	\N
93b58fae-747f-4e51-af20-cad6398513df	Really helpful, thanks!	2024-06-26 18:57:03.305626	2024-06-26 18:57:03.305626	2bdf8bc5-7def-47aa-94ca-7f298307ab35	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
a917329b-a5e9-425c-9176-d457bce237c6	This was okay.	2024-06-26 18:57:03.307455	2024-06-26 18:57:03.307455	b0ed894a-610d-498c-b11f-ed47d2a87b29	72ac885d-73d6-4179-a7ca-71bb98cb5486	\N	\N
5f74b527-0313-41e5-9b60-855bd76fd337	This was okay.	2024-06-26 18:57:03.309012	2024-06-26 18:57:03.309012	220672be-7563-4b84-83f0-cbd497765462	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	\N	\N
1d2d41b9-3ee1-484f-ac2b-f12402921711	Not what I expected.	2024-06-26 18:57:03.310057	2024-06-26 18:57:03.310057	c02fcc25-b9f3-4473-bf1a-80abbdc73474	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
d7b9445b-5bf2-4172-9013-2ec483aee4a4	Great program!	2024-06-26 18:57:03.310911	2024-06-26 18:57:03.310911	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
56ac4718-2625-4156-97b9-9d642aa1b233	Very informative.	2024-06-26 18:57:03.311773	2024-06-26 18:57:03.311773	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	20ff146f-bd26-4272-8dce-016480cf0455	\N	\N
51a255eb-798b-497a-9ba9-c7628d1edf3f	Fantastic!	2024-06-26 18:57:03.312537	2024-06-26 18:57:03.312537	a96df0df-f4a1-4d82-a655-2f7f94ace896	88e39a98-56a3-4d25-936a-21dae870d0b3	\N	\N
d343f761-b804-4687-9164-9d366484907d	Fantastic!	2024-06-26 18:57:03.313186	2024-06-26 18:57:03.313186	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	4997a34d-85e4-4763-83e5-2dc39be7fdd9	\N	\N
ca34bf34-dc32-4355-bb0c-88fb23873615	Fantastic!	2024-06-26 18:57:03.314039	2024-06-26 18:57:03.314039	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
b6aa8f7b-4471-4a3d-b565-91a3bb160eb1	Really helpful, thanks!	2024-06-26 18:57:03.314867	2024-06-26 18:57:03.314867	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	e164f922-a776-40cd-9202-0ac5ebacab76	\N	\N
b3a1c748-ae29-44d5-bc23-9a36e9d3b836	Amazing content.	2024-06-26 18:57:03.316225	2024-06-26 18:57:03.316225	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	72ac885d-73d6-4179-a7ca-71bb98cb5486	\N	\N
7465d4ed-270f-42ef-b823-6b7386a094c1	Loved this episode.	2024-06-26 18:57:03.317046	2024-06-26 18:57:03.317046	5d1b295d-a018-49a2-9c53-a639a3bf51ef	b85d1b4b-f01d-41f8-b273-ac2816c566b5	\N	\N
7ff4f1d6-4fee-4cc0-8743-479c9bb1c1e1	Could be better.	2024-06-26 18:57:03.317894	2024-06-26 18:57:03.317894	c02fcc25-b9f3-4473-bf1a-80abbdc73474	e0ecda2a-7159-4e41-bff6-53a6e34060a8	\N	\N
07ed5942-ac01-4424-a613-809020eee456	Could be better.	2024-06-26 18:57:03.318721	2024-06-26 18:57:03.318721	a96df0df-f4a1-4d82-a655-2f7f94ace896	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
2dc970c2-bd2e-45f7-b4c4-3366f0a5e739	I learned a lot.	2024-06-26 18:57:03.319532	2024-06-26 18:57:03.319532	b0ed894a-610d-498c-b11f-ed47d2a87b29	88e39a98-56a3-4d25-936a-21dae870d0b3	\N	\N
668e70e3-cefa-41de-8905-f637414c9a5f	Really helpful, thanks!	2024-06-26 18:57:03.320635	2024-06-26 18:57:03.320635	f2d14b9e-18a1-4479-a5da-835c7443586f	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	\N	\N
c35479b4-0820-4e79-871f-baf4cb9d0146	I learned a lot.	2024-06-26 18:57:03.32154	2024-06-26 18:57:03.32154	b0afe2ef-0b3d-481d-9654-f9e67207757d	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	\N	\N
3b32854f-0706-4770-a6b3-c8ac856e0c36	Loved this episode.	2024-06-26 18:57:03.322423	2024-06-26 18:57:03.322423	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	\N	\N
056ae510-620f-477e-97d1-bf4ca19e3340	Could be better.	2024-06-26 18:57:03.323217	2024-06-26 18:57:03.323217	f927fc08-8f8a-4a0b-adec-d924091dcad1	b0d45f2b-2442-48cd-8911-591f4fcf0be7	\N	\N
76bcf073-bead-42b8-bacb-48559c1a3b2d	Great program!	2024-06-26 18:57:03.324036	2024-06-26 18:57:03.324036	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
afb619ef-4810-414b-9d55-207483d02ada	Amazing content.	2024-06-26 18:57:03.324754	2024-06-26 18:57:03.324754	d1dbec9d-ce36-42b3-a467-0b1512f41545	b85d1b4b-f01d-41f8-b273-ac2816c566b5	\N	\N
7bd258aa-4e2a-4887-beef-4e5d53421e77	Very informative.	2024-06-26 18:57:03.325409	2024-06-26 18:57:03.325409	b0ed894a-610d-498c-b11f-ed47d2a87b29	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
7f9c2946-4980-4f5c-b1a5-571004c84023	Could be better.	2024-06-26 18:57:03.32605	2024-06-26 18:57:03.32605	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	eb202c43-be73-455e-a9e8-de2724e9a8cd	\N	\N
1f9b80d5-95a3-4ad3-88bc-de6ac8b3d509	Fantastic!	2024-06-26 18:57:03.326716	2024-06-26 18:57:03.326716	f927fc08-8f8a-4a0b-adec-d924091dcad1	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
b8a47c0a-a15e-4caa-8f3c-10cad931e7b8	Really helpful, thanks!	2024-06-26 18:57:03.327549	2024-06-26 18:57:03.327549	d1dbec9d-ce36-42b3-a467-0b1512f41545	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
19c4bc50-e2f6-40d0-a3ff-d248c30995f7	This was okay.	2024-06-26 18:57:03.328171	2024-06-26 18:57:03.328171	693dab47-5108-490b-9a10-97ff75796112	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
becc99a1-312b-4178-b2ea-0004ea5b136b	Could be better.	2024-06-26 18:57:03.328839	2024-06-26 18:57:03.328839	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	20ff146f-bd26-4272-8dce-016480cf0455	\N	\N
72f71511-25a9-4063-998a-8c71fb1f8d34	Fantastic!	2024-06-26 18:57:03.329443	2024-06-26 18:57:03.329443	a96df0df-f4a1-4d82-a655-2f7f94ace896	eb202c43-be73-455e-a9e8-de2724e9a8cd	\N	\N
1769df14-108a-4a97-87db-01b4679f698a	Could be better.	2024-06-26 18:57:03.330108	2024-06-26 18:57:03.330108	7575e78a-a78b-4900-9fb3-b30c925e5f89	b85d1b4b-f01d-41f8-b273-ac2816c566b5	\N	\N
03976ad5-b496-4943-a33b-ee3557a7170d	Amazing content.	2024-06-26 18:57:03.330753	2024-06-26 18:57:03.330753	a9b20768-6469-4d39-b0aa-c4ed19ae9897	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
7bfb37c9-b0a7-4865-a9b2-62a6254b2143	Very informative.	2024-06-26 18:57:03.331363	2024-06-26 18:57:03.331363	9e00a085-1e03-4bb5-b18d-65d93f16f743	0f81f051-ed2a-4931-87bf-544c4f6fe647	\N	\N
4a575ebb-88bf-46e1-8ca3-1637bf06f8d6	Amazing content.	2024-06-26 18:57:03.332303	2024-06-26 18:57:03.332303	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
1fa19c09-7455-468b-9147-7e4bae9f66a1	Could be better.	2024-06-26 18:57:03.332955	2024-06-26 18:57:03.332955	f927fc08-8f8a-4a0b-adec-d924091dcad1	0f81f051-ed2a-4931-87bf-544c4f6fe647	\N	\N
dd2a9b71-23e3-4d73-ae30-298c7614ac70	Could be better.	2024-06-26 18:57:03.333535	2024-06-26 18:57:03.333535	f3c04916-f30d-4360-b465-c5eb262dce94	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	\N	\N
32168cbc-1cb7-42bb-8591-114bcba7b997	Really helpful, thanks!	2024-06-26 18:57:03.334122	2024-06-26 18:57:03.334122	7575e78a-a78b-4900-9fb3-b30c925e5f89	327c8fef-d34c-45e8-aec2-0d226e8347ad	\N	\N
9709a4f5-128b-408c-ab9d-5b78298a92b4	Fantastic!	2024-06-26 18:57:03.334682	2024-06-26 18:57:03.334682	d1ec15b3-32ad-42af-b82b-32e4ccccca84	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
dabf3990-e0f7-4d6d-943f-474f5c7690e9	I learned a lot.	2024-06-26 18:57:03.335205	2024-06-26 18:57:03.335205	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
33f69545-293a-462f-9d9f-73e7dca5cc62	Very informative.	2024-06-26 18:57:03.335751	2024-06-26 18:57:03.335751	b0ed894a-610d-498c-b11f-ed47d2a87b29	72ac885d-73d6-4179-a7ca-71bb98cb5486	\N	\N
9a6965fc-ac7d-413f-b284-c51e394ada8b	Very informative.	2024-06-26 18:57:03.336313	2024-06-26 18:57:03.336313	5d1b295d-a018-49a2-9c53-a639a3bf51ef	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
16417a83-84e4-48aa-b2cf-f3872e879b8e	Could be better.	2024-06-26 18:57:03.336924	2024-06-26 18:57:03.336924	7575e78a-a78b-4900-9fb3-b30c925e5f89	20ff146f-bd26-4272-8dce-016480cf0455	\N	\N
698f3627-80dd-4575-9f9e-cfac472084b3	Loved this episode.	2024-06-26 18:57:03.337515	2024-06-26 18:57:03.337515	cd3675d5-61d6-4adf-96d8-bb5867342208	e0ecda2a-7159-4e41-bff6-53a6e34060a8	\N	\N
d38cc35c-1a05-4dde-89fb-cbe5880bf2f9	I learned a lot.	2024-06-26 18:57:03.338082	2024-06-26 18:57:03.338082	7575e78a-a78b-4900-9fb3-b30c925e5f89	b85d1b4b-f01d-41f8-b273-ac2816c566b5	\N	\N
385fef19-f322-4ccf-8566-d4c708ae4242	Loved this episode.	2024-06-26 18:57:03.338628	2024-06-26 18:57:03.338628	f2d14b9e-18a1-4479-a5da-835c7443586f	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
17afe879-de2e-4205-87d6-82d03708121c	Really helpful, thanks!	2024-06-26 18:57:03.339185	2024-06-26 18:57:03.339185	4ac4c910-d783-48d5-ae41-b542e8cb666f	e0ecda2a-7159-4e41-bff6-53a6e34060a8	\N	\N
085ff166-dd51-4935-9b3f-82ddc0f084cd	Could be better.	2024-06-26 18:57:03.339728	2024-06-26 18:57:03.339728	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
402533ac-104d-4539-82d4-8ca506d44094	This was okay.	2024-06-26 18:57:03.34027	2024-06-26 18:57:03.34027	31c3d5b3-8c7c-4cef-a037-2eccb1839791	20ff146f-bd26-4272-8dce-016480cf0455	\N	\N
877ab8f3-f55f-44ce-a454-fd7a8d29139a	Really helpful, thanks!	2024-06-26 18:57:03.340755	2024-06-26 18:57:03.340755	9e00a085-1e03-4bb5-b18d-65d93f16f743	e164f922-a776-40cd-9202-0ac5ebacab76	\N	\N
dafff9b0-018c-471f-af81-0d7f3f632610	This was okay.	2024-06-26 18:57:03.341241	2024-06-26 18:57:03.341241	cd3675d5-61d6-4adf-96d8-bb5867342208	4997a34d-85e4-4763-83e5-2dc39be7fdd9	\N	\N
f82ef4c1-477e-40f7-9add-14c7837a4f92	Loved this episode.	2024-06-26 18:57:03.341719	2024-06-26 18:57:03.341719	cd3675d5-61d6-4adf-96d8-bb5867342208	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
d81ec82d-06f8-4630-beb7-4aff4b0aba8e	I learned a lot.	2024-06-26 18:57:03.342242	2024-06-26 18:57:03.342242	0f6a77b3-b0c1-420a-943d-2ca4b161991d	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
419fe232-7982-4e8a-9bd6-49ae4aa837c3	I learned a lot.	2024-06-26 18:57:03.34277	2024-06-26 18:57:03.34277	a9b20768-6469-4d39-b0aa-c4ed19ae9897	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
c6afd46d-fd8f-48e5-b02e-8588ca23041c	Loved this episode.	2024-06-26 18:57:03.343244	2024-06-26 18:57:03.343244	64d12d2a-f5a9-4109-b79f-561e15f878b6	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
32d319b0-9a8b-4614-a756-b15ad372a22b	I learned a lot.	2024-06-26 18:57:03.343801	2024-06-26 18:57:03.343801	6a766343-b2eb-491f-8abb-ac90dd69fa95	72ac885d-73d6-4179-a7ca-71bb98cb5486	\N	\N
ed7ed260-b418-4595-beb3-ff00f0c5fe6e	This was okay.	2024-06-26 18:57:03.344279	2024-06-26 18:57:03.344279	6a766343-b2eb-491f-8abb-ac90dd69fa95	e164f922-a776-40cd-9202-0ac5ebacab76	\N	\N
9667109e-cab3-4d9d-8f64-d0bbb037f4a5	Not what I expected.	2024-06-26 18:57:03.344785	2024-06-26 18:57:03.344785	31c3d5b3-8c7c-4cef-a037-2eccb1839791	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	\N	\N
8e5ae1f1-69e4-4353-8756-ee325795a747	Great program!	2024-06-26 18:57:03.345294	2024-06-26 18:57:03.345294	cd3675d5-61d6-4adf-96d8-bb5867342208	4997a34d-85e4-4763-83e5-2dc39be7fdd9	\N	\N
fbbc0331-618d-4f42-a16e-8aad57fc8b7f	Really helpful, thanks!	2024-06-26 18:57:03.345758	2024-06-26 18:57:03.345758	d9500d74-9405-4bb6-89b9-6b19147f2cc8	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	\N	\N
528fdc9b-7f72-4f8c-87b1-e900c5ce77f9	Amazing content.	2024-06-26 18:57:03.346256	2024-06-26 18:57:03.346256	b0afe2ef-0b3d-481d-9654-f9e67207757d	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	\N	\N
abf8df35-6811-4a25-a96f-b57577fa2522	Not what I expected.	2024-06-26 18:57:03.346794	2024-06-26 18:57:03.346794	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	20ff146f-bd26-4272-8dce-016480cf0455	\N	\N
b40637ed-95a6-4628-9f89-5b5834ac9688	Fantastic!	2024-06-26 18:57:03.347261	2024-06-26 18:57:03.347261	64d12d2a-f5a9-4109-b79f-561e15f878b6	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
e5a0b642-0fe3-45c4-95ec-7b6a5621e88b	Very informative.	2024-06-26 18:57:03.34772	2024-06-26 18:57:03.34772	7575e78a-a78b-4900-9fb3-b30c925e5f89	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
1f95588e-e597-4ef3-a815-6e535e07e8a2	Not what I expected.	2024-06-26 18:57:03.348221	2024-06-26 18:57:03.348221	7575e78a-a78b-4900-9fb3-b30c925e5f89	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
fe4ecaeb-f7ea-4655-b7ea-c43ea0cff795	Really helpful, thanks!	2024-06-26 18:57:03.348695	2024-06-26 18:57:03.348695	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	327c8fef-d34c-45e8-aec2-0d226e8347ad	\N	\N
e7606a6c-7669-46de-9d06-96648c044d8f	Really helpful, thanks!	2024-06-26 18:57:03.349823	2024-06-26 18:57:03.349823	d1ec15b3-32ad-42af-b82b-32e4ccccca84	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
a21b5743-11bd-4196-9675-8f46defcee65	Loved this episode.	2024-06-26 18:57:03.35033	2024-06-26 18:57:03.35033	4ac4c910-d783-48d5-ae41-b542e8cb666f	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
b42a97b1-6def-4b3d-b891-aa14a4b84e7e	Really helpful, thanks!	2024-06-26 18:57:03.350867	2024-06-26 18:57:03.350867	2bdf8bc5-7def-47aa-94ca-7f298307ab35	0f81f051-ed2a-4931-87bf-544c4f6fe647	\N	\N
db116b3f-6602-4117-af50-d3930b2ebf79	Not what I expected.	2024-06-26 18:57:03.351353	2024-06-26 18:57:03.351353	04b123c0-c2ed-464f-b848-5637bbd7d89d	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	\N	\N
ff9b287d-af50-4e46-99ec-2614c9f10f3a	Amazing content.	2024-06-26 18:57:03.351818	2024-06-26 18:57:03.351818	960823cf-d908-4246-8fa0-0ac6118797ca	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	\N	\N
5384d11a-bb3b-42e8-a5b7-497ae13414c5	Very informative.	2024-06-26 18:57:03.352276	2024-06-26 18:57:03.352276	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	\N	\N
c2933be0-ac1a-4cc8-b920-61ed43aeaea4	Could be better.	2024-06-26 18:57:03.352764	2024-06-26 18:57:03.352764	6a766343-b2eb-491f-8abb-ac90dd69fa95	e0ecda2a-7159-4e41-bff6-53a6e34060a8	\N	\N
2764a839-d346-40bd-8e68-875b61424ef7	Fantastic!	2024-06-26 18:57:03.353245	2024-06-26 18:57:03.353245	a96df0df-f4a1-4d82-a655-2f7f94ace896	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
25c32b41-f542-496c-b2b2-f672568d7123	Great program!	2024-06-26 18:57:03.35366	2024-06-26 18:57:03.35366	b0ed894a-610d-498c-b11f-ed47d2a87b29	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
4f135e6a-ddfc-4cdd-9565-31b87bad77b9	This was okay.	2024-06-26 18:57:03.354102	2024-06-26 18:57:03.354102	2bebe474-6406-409e-904c-ff7865ac755e	25ba8c0b-e206-475b-a899-ebf6ddb9f593	\N	\N
9c296bbd-aa58-418c-90ac-81177083f00b	Really helpful, thanks!	2024-06-26 18:57:03.354555	2024-06-26 18:57:03.354555	2bdf8bc5-7def-47aa-94ca-7f298307ab35	327c8fef-d34c-45e8-aec2-0d226e8347ad	\N	\N
23ae6245-573a-487f-98a6-16209b94f5ca	Could be better.	2024-06-26 18:57:03.355376	2024-06-26 18:57:03.355376	f927fc08-8f8a-4a0b-adec-d924091dcad1	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	\N	\N
09acce1f-66f7-459b-8b68-d30b0e5c5341	Not what I expected.	2024-06-26 18:57:03.355922	2024-06-26 18:57:03.355922	960823cf-d908-4246-8fa0-0ac6118797ca	b85d1b4b-f01d-41f8-b273-ac2816c566b5	\N	\N
d336d7ad-893b-478f-86ca-acb844ebfcc4	Amazing content.	2024-06-26 18:57:03.35652	2024-06-26 18:57:03.35652	f2d14b9e-18a1-4479-a5da-835c7443586f	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	\N	\N
af471d9d-13ef-45e2-81a4-4ebacf5f36d9	Loved this episode.	2024-06-26 18:57:03.356992	2024-06-26 18:57:03.356992	cd3675d5-61d6-4adf-96d8-bb5867342208	b85d1b4b-f01d-41f8-b273-ac2816c566b5	\N	\N
7d2f6bf5-0a57-4c06-ba40-3072bc42b845	Really helpful, thanks!	2024-06-26 18:57:03.357462	2024-06-26 18:57:03.357462	64d12d2a-f5a9-4109-b79f-561e15f878b6	20ff146f-bd26-4272-8dce-016480cf0455	\N	\N
92561b16-3c4f-48a2-a41c-b79536a21f27	Very informative.	2024-06-26 18:57:03.357894	2024-06-26 18:57:03.357894	04b123c0-c2ed-464f-b848-5637bbd7d89d	b94a2717-25d8-4468-86ef-ff848914d361	\N	\N
5583807d-745e-4168-a872-0c430d3da062	Great program!	2024-06-26 18:57:03.358299	2024-06-26 18:57:03.358299	d1dbec9d-ce36-42b3-a467-0b1512f41545	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	\N	\N
6ffa865e-5010-4825-83c8-890935682f7f	Great program!	2024-06-26 18:57:03.358761	2024-06-26 18:57:03.358761	693dab47-5108-490b-9a10-97ff75796112	b0d45f2b-2442-48cd-8911-591f4fcf0be7	\N	\N
cc351453-b4a7-4e8a-872b-7949ab3074eb	Loved this episode.	2024-06-26 18:57:03.359177	2024-06-26 18:57:03.359177	7d2d10ef-c751-4b4c-aff4-8f47c9952491	327c8fef-d34c-45e8-aec2-0d226e8347ad	\N	\N
a18162dc-1ce3-4052-883a-39a1767da5d5	This was okay.	2024-06-26 18:57:03.359585	2024-06-26 18:57:03.359585	f927fc08-8f8a-4a0b-adec-d924091dcad1	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
37635546-b21c-48fd-8fcd-46cf3fee4ecd	Very informative.	2024-06-26 18:57:03.362496	2024-06-26 18:57:03.362496	9e00a085-1e03-4bb5-b18d-65d93f16f743	72ac885d-73d6-4179-a7ca-71bb98cb5486	\N	\N
27336621-b8ff-4bf1-a725-738a5cf92695	Really helpful, thanks!	2024-06-26 18:57:03.363689	2024-06-26 18:57:03.363689	cd3675d5-61d6-4adf-96d8-bb5867342208	eb202c43-be73-455e-a9e8-de2724e9a8cd	\N	\N
e3ac47f0-c33e-4650-9cfc-22648e9a95ea	I learned a lot.	2024-06-26 18:57:03.364313	2024-06-26 18:57:03.364313	5d1b295d-a018-49a2-9c53-a639a3bf51ef	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
d47f5e1d-bd21-4ab7-ad5c-706d57538c72	Fantastic!	2024-06-26 18:57:03.364987	2024-06-26 18:57:03.364987	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	b85d1b4b-f01d-41f8-b273-ac2816c566b5	\N	\N
8cb37c41-b447-4778-af7e-74efb29e36ab	I learned a lot.	2024-06-26 18:57:03.366065	2024-06-26 18:57:03.366065	b0afe2ef-0b3d-481d-9654-f9e67207757d	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	\N	\N
aee287b4-c046-4689-a1bc-d25ccdb6d289	Could be better.	2024-06-26 18:57:03.36775	2024-06-26 18:57:03.36775	7d2d10ef-c751-4b4c-aff4-8f47c9952491	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	\N	\N
5ab87a52-33a6-4575-a2cd-b66728a18d24	Really helpful, thanks!	2024-06-26 18:57:03.368964	2024-06-26 18:57:03.368964	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	d5e3fdde-0228-487b-a591-f00f3ba3722b	\N	\N
491e1ae4-fde4-4a7d-a825-452d533de069	Loved this episode.	2024-06-26 18:57:03.369358	2024-06-26 18:57:03.369358	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	0f81f051-ed2a-4931-87bf-544c4f6fe647	\N	\N
6a005a99-4ad4-4082-b757-e63028cc75fc	Not what I expected.	2024-06-26 18:57:03.369664	2024-06-26 18:57:03.369664	9e00a085-1e03-4bb5-b18d-65d93f16f743	e164f922-a776-40cd-9202-0ac5ebacab76	\N	\N
0406b9d0-6fbb-4c18-b0be-703eb52a7d36	Not what I expected.	2024-06-26 18:57:03.369992	2024-06-26 18:57:03.369992	b0afe2ef-0b3d-481d-9654-f9e67207757d	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	\N	\N
91f6031b-e067-4d39-a5a5-d67b4330b0c9	Amazing content.	2024-06-26 18:57:03.370318	2024-06-26 18:57:03.370318	960823cf-d908-4246-8fa0-0ac6118797ca	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	\N	\N
9230e47d-8b0d-41b3-ba72-f9ecef6852ab	Loved this episode.	2024-06-26 18:57:03.370636	2024-06-26 18:57:03.370636	04b123c0-c2ed-464f-b848-5637bbd7d89d	dd7734cc-3f4f-48ac-bcea-f38a122ab792	\N	\N
552668b8-7f70-448b-bcf4-714d1a9922cd	Not what I expected.	2024-06-26 18:59:59.585072	2024-06-26 18:59:59.585072	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	dd7734cc-3f4f-48ac-bcea-f38a122ab792	10	\N
c3c34bb8-1635-462a-92cd-ba11f058bd9c	Not what I expected.	2024-06-26 18:59:59.594714	2024-06-26 18:59:59.594714	64d12d2a-f5a9-4109-b79f-561e15f878b6	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	0	\N
bf6b4872-b357-43e7-9661-93d0c385270b	Fantastic!	2024-06-26 18:59:59.598574	2024-06-26 18:59:59.598574	9e00a085-1e03-4bb5-b18d-65d93f16f743	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	5	\N
87480253-479d-47c6-b9ad-08b720574822	Loved this episode.	2024-06-26 18:59:59.600696	2024-06-26 18:59:59.600696	2bdba617-734f-48a5-844c-c7ca5a68781b	88e39a98-56a3-4d25-936a-21dae870d0b3	10	\N
8824ba77-afa1-460c-a06c-f2d4896f59fc	Not what I expected.	2024-06-26 18:59:59.602316	2024-06-26 18:59:59.602316	645dce1e-7159-4b1b-86f0-0bc601f77b4a	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	10	\N
231c2be4-48a1-4ef9-9e1b-178fda0f9667	I learned a lot.	2024-06-26 18:59:59.603384	2024-06-26 18:59:59.603384	693dab47-5108-490b-9a10-97ff75796112	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	2	\N
d5818fb5-deb9-4775-97e4-4e42f18a5963	I learned a lot.	2024-06-26 18:59:59.604145	2024-06-26 18:59:59.604145	220672be-7563-4b84-83f0-cbd497765462	d5e3fdde-0228-487b-a591-f00f3ba3722b	4	\N
9f4c2a2a-2bcd-46c0-b750-715b63bb1a8a	Amazing content.	2024-06-26 18:59:59.604705	2024-06-26 18:59:59.604705	b0afe2ef-0b3d-481d-9654-f9e67207757d	20ff146f-bd26-4272-8dce-016480cf0455	3	\N
5987fe7e-ffcd-4a3f-bb5b-480b431e71d3	Could be better.	2024-06-26 18:59:59.605193	2024-06-26 18:59:59.605193	6a766343-b2eb-491f-8abb-ac90dd69fa95	25ba8c0b-e206-475b-a899-ebf6ddb9f593	4	\N
60920bb5-c961-4c37-a63c-595599603647	Really helpful, thanks!	2024-06-26 18:59:59.605746	2024-06-26 18:59:59.605746	d9500d74-9405-4bb6-89b9-6b19147f2cc8	25ba8c0b-e206-475b-a899-ebf6ddb9f593	4	\N
61ba6f04-cfbd-4201-804f-b166a4071e11	Loved this episode.	2024-06-26 18:59:59.60623	2024-06-26 18:59:59.60623	645dce1e-7159-4b1b-86f0-0bc601f77b4a	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	5	\N
8b93ab80-68bd-434d-8b3c-bb871158c5bb	Loved this episode.	2024-06-26 18:59:59.606706	2024-06-26 18:59:59.606706	04b123c0-c2ed-464f-b848-5637bbd7d89d	88e39a98-56a3-4d25-936a-21dae870d0b3	0	\N
a91ae070-8b4a-4a36-882f-aab6bb5585e5	Very informative.	2024-06-26 18:59:59.60743	2024-06-26 18:59:59.60743	f927fc08-8f8a-4a0b-adec-d924091dcad1	25ba8c0b-e206-475b-a899-ebf6ddb9f593	1	\N
ee128ed7-a268-4bdb-81fb-f26957489a5d	Fantastic!	2024-06-26 18:59:59.608471	2024-06-26 18:59:59.608471	745820cf-14e3-4837-be8a-2f7151ec9131	327c8fef-d34c-45e8-aec2-0d226e8347ad	3	\N
93da737c-0963-4301-88bb-dcd7ce1cad90	Very informative.	2024-06-26 18:59:59.609289	2024-06-26 18:59:59.609289	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	b85d1b4b-f01d-41f8-b273-ac2816c566b5	6	\N
e371aff7-3da9-49f4-8eba-2dad40c88f0c	I learned a lot.	2024-06-26 18:59:59.609966	2024-06-26 18:59:59.609966	f2d14b9e-18a1-4479-a5da-835c7443586f	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	10	\N
f65fc16b-0667-415f-82cd-19cf010d58a8	Very informative.	2024-06-26 18:59:59.611554	2024-06-26 18:59:59.611554	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	eb202c43-be73-455e-a9e8-de2724e9a8cd	8	\N
c0345ea5-d884-4e51-a74e-a306d06dddc3	Very informative.	2024-06-26 18:59:59.612693	2024-06-26 18:59:59.612693	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	8	\N
94170c86-4c65-4c8e-874b-993e38827903	This was okay.	2024-06-26 18:59:59.613285	2024-06-26 18:59:59.613285	a96df0df-f4a1-4d82-a655-2f7f94ace896	0f81f051-ed2a-4931-87bf-544c4f6fe647	6	\N
813a879d-b1f2-4c23-849b-4f59c3220ce2	I learned a lot.	2024-06-26 18:59:59.61387	2024-06-26 18:59:59.61387	2bdf8bc5-7def-47aa-94ca-7f298307ab35	e0ecda2a-7159-4e41-bff6-53a6e34060a8	1	\N
fea0d3d9-f306-466d-a22b-8a2c3158a96b	I learned a lot.	2024-06-26 18:59:59.614328	2024-06-26 18:59:59.614328	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	4997a34d-85e4-4763-83e5-2dc39be7fdd9	1	\N
383a98d8-730e-4436-baf2-45cee3f8eaa8	Very informative.	2024-06-26 18:59:59.615084	2024-06-26 18:59:59.615084	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	6	\N
ea5ba605-bf75-41cf-9ad3-59a911735909	Loved this episode.	2024-06-26 18:59:59.615529	2024-06-26 18:59:59.615529	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	2	\N
e1981c98-5ea2-4ba3-bbe6-b14cb252831e	Amazing content.	2024-06-26 18:59:59.615858	2024-06-26 18:59:59.615858	745820cf-14e3-4837-be8a-2f7151ec9131	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	8	\N
dda81f1d-b126-4fad-8113-5f7cc6ce724a	Fantastic!	2024-06-26 18:59:59.616316	2024-06-26 18:59:59.616316	04b123c0-c2ed-464f-b848-5637bbd7d89d	eb202c43-be73-455e-a9e8-de2724e9a8cd	7	\N
b433a3dc-3714-480f-820a-65f040393b59	Amazing content.	2024-06-26 18:59:59.616686	2024-06-26 18:59:59.616686	d9500d74-9405-4bb6-89b9-6b19147f2cc8	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	6	\N
a68b1ce6-f9ec-4639-87b2-12af5405401c	Really helpful, thanks!	2024-06-26 18:59:59.617055	2024-06-26 18:59:59.617055	f3c04916-f30d-4360-b465-c5eb262dce94	b85d1b4b-f01d-41f8-b273-ac2816c566b5	7	\N
8a6e11aa-cbe2-4cc6-867b-349cd735cb83	Could be better.	2024-06-26 18:59:59.617436	2024-06-26 18:59:59.617436	f927fc08-8f8a-4a0b-adec-d924091dcad1	b0d45f2b-2442-48cd-8911-591f4fcf0be7	5	\N
1fe60f53-eaa9-42eb-b163-2c19e61a75e5	Fantastic!	2024-06-26 18:59:59.61792	2024-06-26 18:59:59.61792	6a766343-b2eb-491f-8abb-ac90dd69fa95	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	10	\N
8c772c6a-4860-4fb5-a3d7-4304f1c1593f	Great program!	2024-06-26 18:59:59.618273	2024-06-26 18:59:59.618273	b0ed894a-610d-498c-b11f-ed47d2a87b29	e164f922-a776-40cd-9202-0ac5ebacab76	0	\N
d87af6da-4472-4437-9d2f-12953438dbb4	Really helpful, thanks!	2024-06-26 18:59:59.618686	2024-06-26 18:59:59.618686	d1ec15b3-32ad-42af-b82b-32e4ccccca84	72ac885d-73d6-4179-a7ca-71bb98cb5486	5	\N
95444d29-9e2e-4af3-a99e-f2508ea94e76	Loved this episode.	2024-06-26 18:59:59.619341	2024-06-26 18:59:59.619341	0f6a77b3-b0c1-420a-943d-2ca4b161991d	eb202c43-be73-455e-a9e8-de2724e9a8cd	6	\N
d7feecdc-bc29-4c24-9850-37bf470fc255	Could be better.	2024-06-26 18:59:59.619711	2024-06-26 18:59:59.619711	0f6a77b3-b0c1-420a-943d-2ca4b161991d	d5e3fdde-0228-487b-a591-f00f3ba3722b	8	\N
f3d89d6f-d660-451e-9bde-815ce3f91e64	Very informative.	2024-06-26 18:59:59.620093	2024-06-26 18:59:59.620093	f3c04916-f30d-4360-b465-c5eb262dce94	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	7	\N
e36b90f4-ca4a-4414-b729-dc8375bcd173	Fantastic!	2024-06-26 18:59:59.620446	2024-06-26 18:59:59.620446	9e00a085-1e03-4bb5-b18d-65d93f16f743	e0ecda2a-7159-4e41-bff6-53a6e34060a8	2	\N
354aba4e-eef4-4a47-891c-f802a49bd54e	Great program!	2024-06-26 18:59:59.620807	2024-06-26 18:59:59.620807	c02fcc25-b9f3-4473-bf1a-80abbdc73474	e164f922-a776-40cd-9202-0ac5ebacab76	1	\N
a0b23eba-228e-4297-a5e9-f3f23f2558fc	This was okay.	2024-06-26 18:59:59.621205	2024-06-26 18:59:59.621205	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	20ff146f-bd26-4272-8dce-016480cf0455	1	\N
08c33c31-f116-4136-b4ef-d9b8f8af0e5b	This was okay.	2024-06-26 18:59:59.621604	2024-06-26 18:59:59.621604	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	327c8fef-d34c-45e8-aec2-0d226e8347ad	1	\N
d1cec815-2867-421e-82ef-0129f7345be3	Fantastic!	2024-06-26 18:59:59.621983	2024-06-26 18:59:59.621983	a96df0df-f4a1-4d82-a655-2f7f94ace896	dd7734cc-3f4f-48ac-bcea-f38a122ab792	5	\N
62fec5cf-5520-44c8-9db5-839dc7fdfe1f	Could be better.	2024-06-26 18:59:59.622425	2024-06-26 18:59:59.622425	04b123c0-c2ed-464f-b848-5637bbd7d89d	d5e3fdde-0228-487b-a591-f00f3ba3722b	7	\N
1c04d1da-262e-4431-b605-7c3552f002fc	Not what I expected.	2024-06-26 18:59:59.623133	2024-06-26 18:59:59.623133	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	4997a34d-85e4-4763-83e5-2dc39be7fdd9	9	\N
f31ff1e4-fc31-4b98-9e13-c43d901e499d	Could be better.	2024-06-26 18:59:59.623541	2024-06-26 18:59:59.623541	0f6a77b3-b0c1-420a-943d-2ca4b161991d	25ba8c0b-e206-475b-a899-ebf6ddb9f593	10	\N
5b8bcb50-6099-4b5c-9815-b11ca49dbb10	Not what I expected.	2024-06-26 18:59:59.624021	2024-06-26 18:59:59.624021	2bebe474-6406-409e-904c-ff7865ac755e	20ff146f-bd26-4272-8dce-016480cf0455	5	\N
47468cd8-9cd9-45f5-83bc-d3774978514d	Amazing content.	2024-06-26 18:59:59.624535	2024-06-26 18:59:59.624535	f2d14b9e-18a1-4479-a5da-835c7443586f	4997a34d-85e4-4763-83e5-2dc39be7fdd9	5	\N
23ed4910-4d8b-4272-ae32-f7b625d1b6ce	Really helpful, thanks!	2024-06-26 18:59:59.624958	2024-06-26 18:59:59.624958	d1ec15b3-32ad-42af-b82b-32e4ccccca84	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	9	\N
6d2206bc-46ab-433d-a730-f39a8d10dda5	Not what I expected.	2024-06-26 18:59:59.625303	2024-06-26 18:59:59.625303	c02fcc25-b9f3-4473-bf1a-80abbdc73474	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	2	\N
d24dc316-0653-4027-9534-71ba5274487b	I learned a lot.	2024-06-26 18:59:59.625678	2024-06-26 18:59:59.625678	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	b94a2717-25d8-4468-86ef-ff848914d361	4	\N
4f507295-7dbe-4e2f-946e-ace56a86f011	Fantastic!	2024-06-26 18:59:59.626032	2024-06-26 18:59:59.626032	16eca672-7fea-4e30-a715-4aaac96518ce	e164f922-a776-40cd-9202-0ac5ebacab76	9	\N
99963a5d-ae8f-4a98-811d-3ac657ece530	Really helpful, thanks!	2024-06-26 18:59:59.626373	2024-06-26 18:59:59.626373	cd3675d5-61d6-4adf-96d8-bb5867342208	4997a34d-85e4-4763-83e5-2dc39be7fdd9	1	\N
dcd0346c-443d-410c-85f5-475c3365f067	Fantastic!	2024-06-26 18:59:59.626763	2024-06-26 18:59:59.626763	6a766343-b2eb-491f-8abb-ac90dd69fa95	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	7	\N
c2a9aa7a-1ee5-4803-bf47-2c7402ee0738	Very informative.	2024-06-26 18:59:59.627109	2024-06-26 18:59:59.627109	220672be-7563-4b84-83f0-cbd497765462	d5e3fdde-0228-487b-a591-f00f3ba3722b	8	\N
44c5b13c-00b7-4035-9656-267228abf935	Loved this episode.	2024-06-26 18:59:59.627411	2024-06-26 18:59:59.627411	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	20ff146f-bd26-4272-8dce-016480cf0455	7	\N
dab157fa-a237-4121-8a48-d8874ca0427e	Very informative.	2024-06-26 18:59:59.62773	2024-06-26 18:59:59.62773	31c3d5b3-8c7c-4cef-a037-2eccb1839791	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	2	\N
82b0a1aa-38c3-441d-8d83-6369752fed3f	Amazing content.	2024-06-26 18:59:59.628063	2024-06-26 18:59:59.628063	a96df0df-f4a1-4d82-a655-2f7f94ace896	b0d45f2b-2442-48cd-8911-591f4fcf0be7	2	\N
52f6d624-b711-45ae-997b-1d41be73a03e	Not what I expected.	2024-06-26 18:59:59.628383	2024-06-26 18:59:59.628383	2bebe474-6406-409e-904c-ff7865ac755e	dd7734cc-3f4f-48ac-bcea-f38a122ab792	0	\N
77720149-111e-4103-bd83-8ddc47235f34	This was okay.	2024-06-26 18:59:59.628695	2024-06-26 18:59:59.628695	04b123c0-c2ed-464f-b848-5637bbd7d89d	88e39a98-56a3-4d25-936a-21dae870d0b3	5	\N
d531d363-c34b-45b3-82ff-92c69780b12d	Amazing content.	2024-06-26 18:59:59.628977	2024-06-26 18:59:59.628977	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	eb202c43-be73-455e-a9e8-de2724e9a8cd	7	\N
4daa6d37-e518-4125-b5d7-448f95ce8ffd	Fantastic!	2024-06-26 18:59:59.629258	2024-06-26 18:59:59.629258	0f6a77b3-b0c1-420a-943d-2ca4b161991d	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	2	\N
9b792b15-6ca2-47d0-8234-f087f6538c5e	Really helpful, thanks!	2024-06-26 18:59:59.629609	2024-06-26 18:59:59.629609	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	25ba8c0b-e206-475b-a899-ebf6ddb9f593	6	\N
5ca8ab48-bbba-4002-88b5-1ce5126ab16f	Fantastic!	2024-06-26 18:59:59.629949	2024-06-26 18:59:59.629949	220672be-7563-4b84-83f0-cbd497765462	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	2	\N
acc6b51c-b3a3-4677-bd08-683bb5ddf70c	Really helpful, thanks!	2024-06-26 18:59:59.630405	2024-06-26 18:59:59.630405	2bdf8bc5-7def-47aa-94ca-7f298307ab35	eb202c43-be73-455e-a9e8-de2724e9a8cd	8	\N
8597ee43-1509-4dd6-a98f-c22fe4e877ac	Could be better.	2024-06-26 18:59:59.630797	2024-06-26 18:59:59.630797	31c3d5b3-8c7c-4cef-a037-2eccb1839791	e164f922-a776-40cd-9202-0ac5ebacab76	10	\N
b762a089-bd52-4b6c-a011-78ea3e3cb1d0	Fantastic!	2024-06-26 18:59:59.631162	2024-06-26 18:59:59.631162	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	88e39a98-56a3-4d25-936a-21dae870d0b3	1	\N
c61c5c02-59cf-406c-997b-32f8d7f0cf87	This was okay.	2024-06-26 18:59:59.631601	2024-06-26 18:59:59.631601	cd3675d5-61d6-4adf-96d8-bb5867342208	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	1	\N
77564454-1c8b-43d1-ba32-2404f6b0a943	Could be better.	2024-06-26 18:59:59.632195	2024-06-26 18:59:59.632195	2bebe474-6406-409e-904c-ff7865ac755e	25ba8c0b-e206-475b-a899-ebf6ddb9f593	3	\N
e94c6d21-d969-48c4-bf3f-8413d532e461	I learned a lot.	2024-06-26 18:59:59.632565	2024-06-26 18:59:59.632565	c02fcc25-b9f3-4473-bf1a-80abbdc73474	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	1	\N
edf5b045-a7c6-4520-bc6a-bc6835b3444b	Loved this episode.	2024-06-26 18:59:59.632922	2024-06-26 18:59:59.632922	693dab47-5108-490b-9a10-97ff75796112	b0d45f2b-2442-48cd-8911-591f4fcf0be7	1	\N
444a74bb-5897-4690-b6f9-902f1e27732a	I learned a lot.	2024-06-26 18:59:59.633255	2024-06-26 18:59:59.633255	2bdf8bc5-7def-47aa-94ca-7f298307ab35	b0d45f2b-2442-48cd-8911-591f4fcf0be7	0	\N
f94ca6b5-047b-4a6c-aa0a-5bcacfe10863	Not what I expected.	2024-06-26 18:59:59.633567	2024-06-26 18:59:59.633567	d1ec15b3-32ad-42af-b82b-32e4ccccca84	d5e3fdde-0228-487b-a591-f00f3ba3722b	10	\N
078349ab-a1f3-48a7-b34c-ba3cc8b461eb	Very informative.	2024-06-26 18:59:59.633889	2024-06-26 18:59:59.633889	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	dd7734cc-3f4f-48ac-bcea-f38a122ab792	10	\N
df7897e9-b1d2-4cc3-b1f4-9e76aaf0f4b9	Could be better.	2024-06-26 18:59:59.634191	2024-06-26 18:59:59.634191	f3c04916-f30d-4360-b465-c5eb262dce94	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	6	\N
5af0fc0e-1357-4328-9e73-f23ca2e5f3a8	Really helpful, thanks!	2024-06-26 18:59:59.634504	2024-06-26 18:59:59.634504	f2d14b9e-18a1-4479-a5da-835c7443586f	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	8	\N
3c782eb7-f894-4855-b8bb-3e21eb4a9c62	Could be better.	2024-06-26 18:59:59.634806	2024-06-26 18:59:59.634806	960823cf-d908-4246-8fa0-0ac6118797ca	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	3	\N
b67d9e3b-cc36-48a3-9640-bbf572ede21a	Great program!	2024-06-26 18:59:59.6351	2024-06-26 18:59:59.6351	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	8fe11bba-6a07-4c9d-bafb-2d5682a8444e	5	\N
d910efe2-a986-4740-b216-86a6f0d25f58	Really helpful, thanks!	2024-06-26 18:59:59.635455	2024-06-26 18:59:59.635455	a9b20768-6469-4d39-b0aa-c4ed19ae9897	20ff146f-bd26-4272-8dce-016480cf0455	2	\N
68a4321c-fef5-433a-b257-e2c857892948	Loved this episode.	2024-06-26 18:59:59.635747	2024-06-26 18:59:59.635747	2bebe474-6406-409e-904c-ff7865ac755e	eb202c43-be73-455e-a9e8-de2724e9a8cd	6	\N
4b3ba02c-a5a5-4451-8cc4-66ae2055792b	Very informative.	2024-06-26 18:59:59.636035	2024-06-26 18:59:59.636035	d9500d74-9405-4bb6-89b9-6b19147f2cc8	d5e3fdde-0228-487b-a591-f00f3ba3722b	0	\N
38e1f8dd-1372-4d58-9c4e-288dcf29e58d	I learned a lot.	2024-06-26 18:59:59.636343	2024-06-26 18:59:59.636343	7d2d10ef-c751-4b4c-aff4-8f47c9952491	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	6	\N
17bac984-aeff-4855-8124-e52b94c17bc7	Great program!	2024-06-26 18:59:59.63665	2024-06-26 18:59:59.63665	2bdf8bc5-7def-47aa-94ca-7f298307ab35	b85d1b4b-f01d-41f8-b273-ac2816c566b5	3	\N
939f279d-48fb-4bdb-8238-6809e560eb66	I learned a lot.	2024-06-26 18:59:59.636947	2024-06-26 18:59:59.636947	7575e78a-a78b-4900-9fb3-b30c925e5f89	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	6	\N
9a8bab2a-74fe-41cb-b744-b4495626f951	Fantastic!	2024-06-26 18:59:59.637257	2024-06-26 18:59:59.637257	7575e78a-a78b-4900-9fb3-b30c925e5f89	4997a34d-85e4-4763-83e5-2dc39be7fdd9	9	\N
bf1bd407-bd48-4c54-b1c0-84dc4bf87f5e	Great program!	2024-06-26 18:59:59.637543	2024-06-26 18:59:59.637543	960823cf-d908-4246-8fa0-0ac6118797ca	b85d1b4b-f01d-41f8-b273-ac2816c566b5	10	\N
7af64b2f-c261-49e2-87a0-ec4d2831f946	Fantastic!	2024-06-26 18:59:59.637826	2024-06-26 18:59:59.637826	16eca672-7fea-4e30-a715-4aaac96518ce	327c8fef-d34c-45e8-aec2-0d226e8347ad	8	\N
77c98184-1f66-4e0d-944d-e09c13e196d7	I learned a lot.	2024-06-26 18:59:59.638146	2024-06-26 18:59:59.638146	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	25ba8c0b-e206-475b-a899-ebf6ddb9f593	0	\N
19716141-c978-42a1-8eb3-afd3bc7ae6b1	Amazing content.	2024-06-26 18:59:59.638521	2024-06-26 18:59:59.638521	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	10	\N
c62e3892-693e-48f5-93c9-ff573628ecf6	Great program!	2024-06-26 18:59:59.638935	2024-06-26 18:59:59.638935	220672be-7563-4b84-83f0-cbd497765462	72ac885d-73d6-4179-a7ca-71bb98cb5486	7	\N
5cdd3963-ba6e-40d2-887b-b9da0c3256d9	Loved this episode.	2024-06-26 18:59:59.639352	2024-06-26 18:59:59.639352	2bdf8bc5-7def-47aa-94ca-7f298307ab35	25ba8c0b-e206-475b-a899-ebf6ddb9f593	7	\N
79946b6c-7e67-4793-b55b-e8100eb4114d	Fantastic!	2024-06-26 18:59:59.639709	2024-06-26 18:59:59.639709	6a766343-b2eb-491f-8abb-ac90dd69fa95	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	5	\N
c0fddbc7-6296-48d9-8e4c-1f4967417ccd	Amazing content.	2024-06-26 18:59:59.640026	2024-06-26 18:59:59.640026	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	eb202c43-be73-455e-a9e8-de2724e9a8cd	5	\N
3f0021e4-78db-4f5e-8e72-7c44c23476a2	Loved this episode.	2024-06-26 18:59:59.640314	2024-06-26 18:59:59.640314	64d12d2a-f5a9-4109-b79f-561e15f878b6	e164f922-a776-40cd-9202-0ac5ebacab76	1	\N
fb67dffe-3f7a-4877-bab4-7d55df72f916	Really helpful, thanks!	2024-06-26 18:59:59.6406	2024-06-26 18:59:59.6406	5d1b295d-a018-49a2-9c53-a639a3bf51ef	b0d45f2b-2442-48cd-8911-591f4fcf0be7	7	\N
0f8562c6-98ec-443b-a865-b47fa03d3eb2	Amazing content.	2024-06-26 18:59:59.640916	2024-06-26 18:59:59.640916	645dce1e-7159-4b1b-86f0-0bc601f77b4a	b85d1b4b-f01d-41f8-b273-ac2816c566b5	1	\N
44ddf805-8703-4ef0-a629-d962a3db3ae0	I learned a lot.	2024-06-26 18:59:59.641201	2024-06-26 18:59:59.641201	04b123c0-c2ed-464f-b848-5637bbd7d89d	b85d1b4b-f01d-41f8-b273-ac2816c566b5	0	\N
858f52c5-da86-4d45-858e-47cf9351b3db	Loved this episode.	2024-06-26 18:59:59.641472	2024-06-26 18:59:59.641472	745820cf-14e3-4837-be8a-2f7151ec9131	20ff146f-bd26-4272-8dce-016480cf0455	6	\N
54cf3e57-a533-4d44-a5ff-8c41753061ee	Great program!	2024-06-26 18:59:59.641812	2024-06-26 18:59:59.641812	16eca672-7fea-4e30-a715-4aaac96518ce	ceb9f2e5-5642-4e62-b043-aac33b13ddb9	2	\N
3aef3d32-f93a-46d9-bb9c-bb3d879bda2a	Really helpful, thanks!	2024-06-26 18:59:59.642144	2024-06-26 18:59:59.642144	4ac4c910-d783-48d5-ae41-b542e8cb666f	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	3	\N
c6dc2125-1f7b-4205-a08b-2706ac5a793c	Very informative.	2024-06-26 18:59:59.642465	2024-06-26 18:59:59.642465	f2d14b9e-18a1-4479-a5da-835c7443586f	0f81f051-ed2a-4931-87bf-544c4f6fe647	4	\N
7729c76c-98ab-4a71-8571-c9715e26807d	Loved this episode.	2024-06-26 18:59:59.64274	2024-06-26 18:59:59.64274	6a766343-b2eb-491f-8abb-ac90dd69fa95	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	9	\N
8f6b2e86-c435-4e07-b011-10be457910c3	I learned a lot.	2024-06-26 18:59:59.643021	2024-06-26 18:59:59.643021	0f6a77b3-b0c1-420a-943d-2ca4b161991d	327c8fef-d34c-45e8-aec2-0d226e8347ad	2	\N
4290f0d8-7f65-4438-938b-e9d8b7d52d12	Amazing content.	2024-06-26 18:59:59.643308	2024-06-26 18:59:59.643308	a96df0df-f4a1-4d82-a655-2f7f94ace896	f78c6ff8-c684-42cf-96e5-729f6eea2c2a	4	\N
\.


--
-- Data for Name: follow; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.follow ("relationId", "followerUserId", "followingUserId") FROM stdin;
638f18a7-3e21-4a83-9365-b83504a3d30a	2bebe474-6406-409e-904c-ff7865ac755e	b0afe2ef-0b3d-481d-9654-f9e67207757d
141802ab-6d33-447d-8f93-928d0fcec7d7	693dab47-5108-490b-9a10-97ff75796112	f927fc08-8f8a-4a0b-adec-d924091dcad1
87d540c6-db9d-41b4-b079-cc661177b5c2	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	2bdba617-734f-48a5-844c-c7ca5a68781b
4329043d-8ccd-4d4c-a52a-7b2526f974c1	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	960823cf-d908-4246-8fa0-0ac6118797ca
1a6f7a6d-5d2e-437f-9279-6674f62021a9	2bdf8bc5-7def-47aa-94ca-7f298307ab35	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
a8a7cb41-385c-4ab4-b869-0f7aacd28e66	745820cf-14e3-4837-be8a-2f7151ec9131	220672be-7563-4b84-83f0-cbd497765462
416882ae-8b1d-4f11-b8da-2b525f3a13e2	b0ed894a-610d-498c-b11f-ed47d2a87b29	2bebe474-6406-409e-904c-ff7865ac755e
13976480-819e-4a6c-8649-d4b8bf393602	960823cf-d908-4246-8fa0-0ac6118797ca	9e00a085-1e03-4bb5-b18d-65d93f16f743
179e3040-85f3-4780-83c2-6d774a81132b	a96df0df-f4a1-4d82-a655-2f7f94ace896	f3c04916-f30d-4360-b465-c5eb262dce94
a7d753f5-6119-4e31-992f-c4af0d99914e	7d2d10ef-c751-4b4c-aff4-8f47c9952491	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
3bb5fead-1cb2-4343-aa48-354939bb4640	f2d14b9e-18a1-4479-a5da-835c7443586f	16eca672-7fea-4e30-a715-4aaac96518ce
cf6f1ccb-ae7b-45c5-b983-f4f8e7154c5d	645dce1e-7159-4b1b-86f0-0bc601f77b4a	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
6497569b-1b00-4e77-a3ac-0694baf0da6f	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	5d1b295d-a018-49a2-9c53-a639a3bf51ef
53677431-5fba-4880-af9b-c27cd38fa158	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	6a766343-b2eb-491f-8abb-ac90dd69fa95
6b742e33-1981-4ae6-b642-1d898b933788	7575e78a-a78b-4900-9fb3-b30c925e5f89	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
eec98404-3ea7-4bf7-a215-29e4c6b5e9f9	d1ec15b3-32ad-42af-b82b-32e4ccccca84	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
36cd0883-36ea-4cb8-94f6-bfe39d9d0a12	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	d1dbec9d-ce36-42b3-a467-0b1512f41545
869ea86e-4171-40a2-9b57-9c26599322b0	960823cf-d908-4246-8fa0-0ac6118797ca	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
ab3d93b7-0a03-43c2-ab54-18632ff3c384	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
f39dcd7d-14a7-41b6-ba0c-00152e65357a	d1ec15b3-32ad-42af-b82b-32e4ccccca84	960823cf-d908-4246-8fa0-0ac6118797ca
64e88ddd-cb31-4e1a-8bc1-374f440a06fb	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	0f6a77b3-b0c1-420a-943d-2ca4b161991d
c0bed99c-3654-42be-8b9e-89497de41e5e	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	f2d14b9e-18a1-4479-a5da-835c7443586f
d301dcfe-5af3-4b2f-9c5b-45683119e673	b0ed894a-610d-498c-b11f-ed47d2a87b29	9e00a085-1e03-4bb5-b18d-65d93f16f743
1a4d82f2-9846-41eb-a60d-3c7cc3dffac5	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
d49ca40f-d970-40b3-a57f-f78d9ce16677	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	2bdf8bc5-7def-47aa-94ca-7f298307ab35
3dd022d6-7ff2-402e-8f9f-eeffa74e051b	04b123c0-c2ed-464f-b848-5637bbd7d89d	693dab47-5108-490b-9a10-97ff75796112
84384344-3289-4fc8-b670-f5919c4dbf00	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	16eca672-7fea-4e30-a715-4aaac96518ce
9fe3306d-85b4-491e-ac4f-327d04291641	a9b20768-6469-4d39-b0aa-c4ed19ae9897	2bdf8bc5-7def-47aa-94ca-7f298307ab35
0c03528a-a169-4c0b-a73e-21d2ea4d1ddd	5d1b295d-a018-49a2-9c53-a639a3bf51ef	c02fcc25-b9f3-4473-bf1a-80abbdc73474
b9214df3-5ce0-4f61-ac8d-62e9f2c02eb7	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	7575e78a-a78b-4900-9fb3-b30c925e5f89
b1ad4eb1-0b99-41f9-9415-dfed79633f9e	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
94cc37c7-dd50-4dfa-9881-697d70a46c8e	31c3d5b3-8c7c-4cef-a037-2eccb1839791	7d2d10ef-c751-4b4c-aff4-8f47c9952491
19339c69-ec7d-42cd-bbc6-06137ef39c73	5d1b295d-a018-49a2-9c53-a639a3bf51ef	16eca672-7fea-4e30-a715-4aaac96518ce
639c0841-73a3-419a-b841-68148e7ad42c	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	64d12d2a-f5a9-4109-b79f-561e15f878b6
44e5c9ab-0397-416a-bf05-32fbb8180cf9	f2d14b9e-18a1-4479-a5da-835c7443586f	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
56e68f4f-6568-4f0e-b6bc-0802c6d622f6	d9500d74-9405-4bb6-89b9-6b19147f2cc8	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
f38a04dc-0ce7-4cdc-b5e7-56f9db846a52	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	7d2d10ef-c751-4b4c-aff4-8f47c9952491
02215f28-8274-400f-9e5a-12399cb3e08a	2bdba617-734f-48a5-844c-c7ca5a68781b	645dce1e-7159-4b1b-86f0-0bc601f77b4a
f7fdfa73-d83c-405e-aca6-67d7d465cb04	645dce1e-7159-4b1b-86f0-0bc601f77b4a	04b123c0-c2ed-464f-b848-5637bbd7d89d
85a1b3d2-2d2f-4b4a-b6a3-8c98915a4cb4	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	c02fcc25-b9f3-4473-bf1a-80abbdc73474
9320e9c0-1662-4824-8e72-ac53575ffee3	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	7575e78a-a78b-4900-9fb3-b30c925e5f89
ec93ce68-f717-4670-a9e4-3282ac8c814b	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	645dce1e-7159-4b1b-86f0-0bc601f77b4a
a77f63cb-808d-43f9-ac7b-7bb10521372b	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	f927fc08-8f8a-4a0b-adec-d924091dcad1
e6f89af6-45c0-42d6-a352-1f7c782c982b	d1dbec9d-ce36-42b3-a467-0b1512f41545	4ac4c910-d783-48d5-ae41-b542e8cb666f
d1b65a6e-7a0d-4eea-bf8e-3d8e7b081669	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
d84f7c21-1202-4fae-ad88-35bce4d797a4	f2d14b9e-18a1-4479-a5da-835c7443586f	693dab47-5108-490b-9a10-97ff75796112
9b042e10-b095-4301-8d6d-ec0783a0fed4	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	7d2d10ef-c751-4b4c-aff4-8f47c9952491
b612d570-c540-4f32-9780-41fa74507261	2bdf8bc5-7def-47aa-94ca-7f298307ab35	d1dbec9d-ce36-42b3-a467-0b1512f41545
515e7daf-4f60-4b97-bab8-baa4c44b16ed	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
8e09cf5b-ee40-4f2d-afa1-a88ae16b8895	f3c04916-f30d-4360-b465-c5eb262dce94	2bdf8bc5-7def-47aa-94ca-7f298307ab35
e830a194-91f2-4843-b441-dbf9264d47cc	7d2d10ef-c751-4b4c-aff4-8f47c9952491	cd3675d5-61d6-4adf-96d8-bb5867342208
3091c3ae-c858-49af-9a1f-af108626d705	7d2d10ef-c751-4b4c-aff4-8f47c9952491	64d12d2a-f5a9-4109-b79f-561e15f878b6
8b9812c3-6202-45c6-9397-e194fcd735d9	d9500d74-9405-4bb6-89b9-6b19147f2cc8	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
16e2c912-e3ec-41a5-8039-1f3409962249	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	f927fc08-8f8a-4a0b-adec-d924091dcad1
d8af1853-620f-47a8-ba28-d03fb76ee8ff	c02fcc25-b9f3-4473-bf1a-80abbdc73474	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
e64975b7-18e5-42c7-888c-858b2ca0b70b	f927fc08-8f8a-4a0b-adec-d924091dcad1	9e00a085-1e03-4bb5-b18d-65d93f16f743
1e659f44-52bc-4012-9189-cd5b191be26b	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
8831fe6a-1c01-43f5-85c1-cdd111c476e7	d1ec15b3-32ad-42af-b82b-32e4ccccca84	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
10bb5126-e825-46d2-ba06-c4633aab70f8	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	64d12d2a-f5a9-4109-b79f-561e15f878b6
dbdd4057-d1fd-4a07-80b0-d9ec45d53cc5	0f6a77b3-b0c1-420a-943d-2ca4b161991d	2bdba617-734f-48a5-844c-c7ca5a68781b
76fff215-c8de-4715-a927-7edfc5639939	745820cf-14e3-4837-be8a-2f7151ec9131	645dce1e-7159-4b1b-86f0-0bc601f77b4a
f2fc9a96-06d6-4c45-95f9-64a3d4c70f49	7575e78a-a78b-4900-9fb3-b30c925e5f89	16eca672-7fea-4e30-a715-4aaac96518ce
efc0791b-bab5-4294-8005-7d3c28ff8dfd	9e00a085-1e03-4bb5-b18d-65d93f16f743	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
3008ad3a-fe77-4c45-b6eb-ab2d751d49f8	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	960823cf-d908-4246-8fa0-0ac6118797ca
d4229c9e-0ed8-47af-84fa-60d7c8d2a653	6a766343-b2eb-491f-8abb-ac90dd69fa95	4ac4c910-d783-48d5-ae41-b542e8cb666f
400ba5e4-5b17-4bfc-b85e-525051523fbc	960823cf-d908-4246-8fa0-0ac6118797ca	c02fcc25-b9f3-4473-bf1a-80abbdc73474
235a6887-a481-4d7d-a09d-ebe174c2590f	2bebe474-6406-409e-904c-ff7865ac755e	64d12d2a-f5a9-4109-b79f-561e15f878b6
cff1ad65-6020-433a-bb8a-04da881ca4a1	2bdf8bc5-7def-47aa-94ca-7f298307ab35	960823cf-d908-4246-8fa0-0ac6118797ca
e3ccd24d-28eb-4f25-83aa-5097d81e60a4	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	a9b20768-6469-4d39-b0aa-c4ed19ae9897
112d0888-2580-450b-8d20-5860672f18fc	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	d1dbec9d-ce36-42b3-a467-0b1512f41545
97d1775b-452a-4376-8066-3a69ebe4b043	a96df0df-f4a1-4d82-a655-2f7f94ace896	16eca672-7fea-4e30-a715-4aaac96518ce
4413ed17-d8b2-459c-ac69-18b1b7617a72	9e00a085-1e03-4bb5-b18d-65d93f16f743	645dce1e-7159-4b1b-86f0-0bc601f77b4a
32ef418b-b774-47b7-9dd5-f08d8101e73c	4ac4c910-d783-48d5-ae41-b542e8cb666f	f3c04916-f30d-4360-b465-c5eb262dce94
e9dec079-4fd7-49f5-bd62-dc0a2bd7b216	960823cf-d908-4246-8fa0-0ac6118797ca	f927fc08-8f8a-4a0b-adec-d924091dcad1
8604dc1e-5cf3-4b0b-9fe8-4c1e884695c4	d9500d74-9405-4bb6-89b9-6b19147f2cc8	0f6a77b3-b0c1-420a-943d-2ca4b161991d
a97b35ae-542f-4ffe-8faf-84ecb0a1a31e	4ac4c910-d783-48d5-ae41-b542e8cb666f	b0ed894a-610d-498c-b11f-ed47d2a87b29
10c68af9-c8a3-466d-af63-f196788b71e3	0f6a77b3-b0c1-420a-943d-2ca4b161991d	4ac4c910-d783-48d5-ae41-b542e8cb666f
e539ff7a-053d-4421-8478-aac248f35058	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
2c3b2079-159e-4dd0-9ee0-4aa949085f81	04b123c0-c2ed-464f-b848-5637bbd7d89d	f3c04916-f30d-4360-b465-c5eb262dce94
98a657bb-3039-4426-ba02-bb830ce2a38a	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
218b917f-57dd-4f0a-aeb3-85fd72bce5d4	d1ec15b3-32ad-42af-b82b-32e4ccccca84	2bdf8bc5-7def-47aa-94ca-7f298307ab35
3e4c133e-8c00-4758-a08c-4b8a432665c2	960823cf-d908-4246-8fa0-0ac6118797ca	b0ed894a-610d-498c-b11f-ed47d2a87b29
4b69bcdf-2a8f-479d-b454-068684df22b5	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
ed1ba7c7-d4b2-41c3-8d16-1cbd40db781a	693dab47-5108-490b-9a10-97ff75796112	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
b00c6616-9fde-4dc0-b721-172891ba6078	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
8dea1a7c-23cb-429e-a059-f93dfb8f7bc6	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	2bdba617-734f-48a5-844c-c7ca5a68781b
5b60517e-ef8f-42b5-8919-ca1e61f8b44a	960823cf-d908-4246-8fa0-0ac6118797ca	31c3d5b3-8c7c-4cef-a037-2eccb1839791
d38aecba-8fbe-459e-bbe6-471c56b5574e	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	693dab47-5108-490b-9a10-97ff75796112
4d5f01dc-b215-4b88-94d7-9463d9c4e35f	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	d1ec15b3-32ad-42af-b82b-32e4ccccca84
c82b2598-a33f-4075-b482-1ac22102e56b	a9b20768-6469-4d39-b0aa-c4ed19ae9897	693dab47-5108-490b-9a10-97ff75796112
4d55f3f3-b9df-4890-bf76-fc33efb64388	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	c02fcc25-b9f3-4473-bf1a-80abbdc73474
b72a1b28-af56-41ed-9e06-2921533c3ec0	f3c04916-f30d-4360-b465-c5eb262dce94	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
4dfd6a0b-50e4-4b34-9add-6645236a81e8	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	f2d14b9e-18a1-4479-a5da-835c7443586f
6df89898-bca3-45a2-a718-f0cf7c715aab	4ac4c910-d783-48d5-ae41-b542e8cb666f	d1ec15b3-32ad-42af-b82b-32e4ccccca84
350fe3c0-af6c-4aee-b234-ca4fa60e8c59	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	4ac4c910-d783-48d5-ae41-b542e8cb666f
57bb203d-67d7-4dfe-9dc9-1fa91aeca228	d1dbec9d-ce36-42b3-a467-0b1512f41545	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
98853db3-777c-441b-a62b-7ff694c596c1	cd3675d5-61d6-4adf-96d8-bb5867342208	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
82044c59-716b-4d2f-8198-fe06098852b3	d9500d74-9405-4bb6-89b9-6b19147f2cc8	5d1b295d-a018-49a2-9c53-a639a3bf51ef
dc5337b7-d78f-48a4-86a1-9ddf68f6b85f	2bdf8bc5-7def-47aa-94ca-7f298307ab35	b0afe2ef-0b3d-481d-9654-f9e67207757d
3783d245-03e6-4e4c-b043-27cd571bc2b7	9e00a085-1e03-4bb5-b18d-65d93f16f743	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
33ed9c3f-8b76-4f71-8a47-5cd471ab893c	6a766343-b2eb-491f-8abb-ac90dd69fa95	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
a512a37d-fe8c-43eb-b255-83618d373baf	cd3675d5-61d6-4adf-96d8-bb5867342208	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
47b6f5cf-7f4d-4243-a8e9-cb61c1de0024	b0ed894a-610d-498c-b11f-ed47d2a87b29	a9b20768-6469-4d39-b0aa-c4ed19ae9897
804654cd-1707-4b8c-9770-67b3b51325b1	5d1b295d-a018-49a2-9c53-a639a3bf51ef	7575e78a-a78b-4900-9fb3-b30c925e5f89
e2fe23f2-4c16-497a-968a-c6ea1a3110e1	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	6a766343-b2eb-491f-8abb-ac90dd69fa95
8069e2da-1d62-4abd-ae9b-d27608fae493	b0ed894a-610d-498c-b11f-ed47d2a87b29	693dab47-5108-490b-9a10-97ff75796112
f44f3b0b-ac77-4f0a-923a-dd1faa1fa30b	cd3675d5-61d6-4adf-96d8-bb5867342208	4ac4c910-d783-48d5-ae41-b542e8cb666f
753665a3-0cc6-4bf4-85e5-7e1d3c190b71	d1ec15b3-32ad-42af-b82b-32e4ccccca84	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
7fb2ff71-0f6e-4987-b19b-5fb5b9468f46	cd3675d5-61d6-4adf-96d8-bb5867342208	0f6a77b3-b0c1-420a-943d-2ca4b161991d
898f896f-d94c-4612-8baf-bdb47b587c08	2bdf8bc5-7def-47aa-94ca-7f298307ab35	4ac4c910-d783-48d5-ae41-b542e8cb666f
d349b839-aa40-47dc-92b0-229a54fdf129	f927fc08-8f8a-4a0b-adec-d924091dcad1	cd3675d5-61d6-4adf-96d8-bb5867342208
5a07e1b4-7b69-4059-9b5a-999734fe3c45	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	220672be-7563-4b84-83f0-cbd497765462
b2428410-8e3e-42da-9314-d870c9800a71	0f6a77b3-b0c1-420a-943d-2ca4b161991d	f2d14b9e-18a1-4479-a5da-835c7443586f
6c0385ad-7ace-4bbb-992c-90aeb0b0ba2d	a9b20768-6469-4d39-b0aa-c4ed19ae9897	f3c04916-f30d-4360-b465-c5eb262dce94
c2ab070a-cea6-4219-b27f-8b3efc990204	f3c04916-f30d-4360-b465-c5eb262dce94	b0afe2ef-0b3d-481d-9654-f9e67207757d
140aab98-0ebe-4c84-8956-a0369222ebc7	220672be-7563-4b84-83f0-cbd497765462	d9500d74-9405-4bb6-89b9-6b19147f2cc8
6aa9fb78-dc7f-4dcc-a436-b7ce10c6dfb2	d9500d74-9405-4bb6-89b9-6b19147f2cc8	d1dbec9d-ce36-42b3-a467-0b1512f41545
d644cb52-35c8-4962-97c3-b2f5b3c7cdbc	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	5d1b295d-a018-49a2-9c53-a639a3bf51ef
e8f1dffe-1b6f-40ac-a7c5-78c41c75be5a	b0afe2ef-0b3d-481d-9654-f9e67207757d	745820cf-14e3-4837-be8a-2f7151ec9131
275dfa66-266b-452a-855a-f4d886d6306f	d1dbec9d-ce36-42b3-a467-0b1512f41545	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
08b5d767-2f55-4036-a63b-167ed725b202	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	f2d14b9e-18a1-4479-a5da-835c7443586f
27abd866-468b-4428-bae9-d07a0d4af86b	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
d8cfcac7-2443-47d8-8b16-67c213eb38b3	a96df0df-f4a1-4d82-a655-2f7f94ace896	2bdf8bc5-7def-47aa-94ca-7f298307ab35
2874adf8-9e9e-485a-8917-bce829fa49fe	04b123c0-c2ed-464f-b848-5637bbd7d89d	d1ec15b3-32ad-42af-b82b-32e4ccccca84
c217a5f7-d2d3-4c53-8a07-937519434897	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	d1ec15b3-32ad-42af-b82b-32e4ccccca84
04d8bc53-9b7f-418f-9ffd-eb4cfab06434	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	7575e78a-a78b-4900-9fb3-b30c925e5f89
a350d1e2-8fb5-425a-b317-97164959ebfd	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	2bdba617-734f-48a5-844c-c7ca5a68781b
3fc2c301-0988-43b8-82f0-fce905a1f39f	c02fcc25-b9f3-4473-bf1a-80abbdc73474	cd3675d5-61d6-4adf-96d8-bb5867342208
ba6d1240-8225-432d-8c76-4168bedd5c3a	a9b20768-6469-4d39-b0aa-c4ed19ae9897	6a766343-b2eb-491f-8abb-ac90dd69fa95
a25ead47-3205-4b1b-a565-199bbd592cee	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	745820cf-14e3-4837-be8a-2f7151ec9131
38e8d8ba-f93f-45da-b931-7a8a494d2ecd	745820cf-14e3-4837-be8a-2f7151ec9131	cd3675d5-61d6-4adf-96d8-bb5867342208
3268809c-016b-418d-92d7-d9f29628f1a7	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	d1dbec9d-ce36-42b3-a467-0b1512f41545
30414668-04b0-4bee-8126-9d0846f9df82	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	04b123c0-c2ed-464f-b848-5637bbd7d89d
82e49b13-f1c6-46f8-b7be-719a64c8fe1b	7575e78a-a78b-4900-9fb3-b30c925e5f89	5d1b295d-a018-49a2-9c53-a639a3bf51ef
b5f8cab6-a857-4405-866f-3618f1f2a65c	04b123c0-c2ed-464f-b848-5637bbd7d89d	a9b20768-6469-4d39-b0aa-c4ed19ae9897
30eab0c6-9d06-48e9-a127-b80da4256a4a	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	7d2d10ef-c751-4b4c-aff4-8f47c9952491
da68a172-5e7c-4cad-ba50-31e825932473	c02fcc25-b9f3-4473-bf1a-80abbdc73474	a9b20768-6469-4d39-b0aa-c4ed19ae9897
9624e617-6e90-445f-890f-237ac915f354	9e00a085-1e03-4bb5-b18d-65d93f16f743	f927fc08-8f8a-4a0b-adec-d924091dcad1
7e303f56-ce9f-4753-ae54-571e7d726e83	6a766343-b2eb-491f-8abb-ac90dd69fa95	2bdba617-734f-48a5-844c-c7ca5a68781b
395b57db-bec8-45e6-89a1-e7415cfb7425	f3c04916-f30d-4360-b465-c5eb262dce94	a9b20768-6469-4d39-b0aa-c4ed19ae9897
c0f20285-686d-460b-a670-1b2a6a8d62d1	0f6a77b3-b0c1-420a-943d-2ca4b161991d	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
06966c4f-0a4b-442f-88e8-74abb5d2f709	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	a9b20768-6469-4d39-b0aa-c4ed19ae9897
cce5b1f5-2994-41e6-bd95-ff68a10aab43	d9500d74-9405-4bb6-89b9-6b19147f2cc8	7575e78a-a78b-4900-9fb3-b30c925e5f89
91381120-ba8d-4f62-bbd2-658257031ae4	7d2d10ef-c751-4b4c-aff4-8f47c9952491	f3c04916-f30d-4360-b465-c5eb262dce94
b7474b8f-6550-40a1-b5fb-9a259907f388	d1dbec9d-ce36-42b3-a467-0b1512f41545	cd3675d5-61d6-4adf-96d8-bb5867342208
2c87abe4-a445-47c6-b9f5-02fd0dee82cf	7575e78a-a78b-4900-9fb3-b30c925e5f89	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
cb6c2bc3-9e99-424b-84c3-3c88fbf3606b	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	16eca672-7fea-4e30-a715-4aaac96518ce
1b8773b9-a53e-4685-95c1-cf5842ab5738	a96df0df-f4a1-4d82-a655-2f7f94ace896	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
ebddcce7-9306-4010-ba6c-b480c7c281c8	745820cf-14e3-4837-be8a-2f7151ec9131	7575e78a-a78b-4900-9fb3-b30c925e5f89
df5eeb0b-a7e8-4abc-ace8-ce956ad0fd92	c02fcc25-b9f3-4473-bf1a-80abbdc73474	645dce1e-7159-4b1b-86f0-0bc601f77b4a
2539db31-b18a-4a81-b1cd-31109594216e	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
fed04ebc-f608-46b7-825c-c451a05d3f6d	745820cf-14e3-4837-be8a-2f7151ec9131	7d2d10ef-c751-4b4c-aff4-8f47c9952491
c8eefbe8-34a7-4744-b9dd-edad5b9c02d0	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	220672be-7563-4b84-83f0-cbd497765462
c6567a7b-ec3d-4051-8f3e-dd7dd0071fae	64d12d2a-f5a9-4109-b79f-561e15f878b6	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
a992efe8-b288-45f0-a48b-aaf70459cfc7	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	2bdba617-734f-48a5-844c-c7ca5a68781b
2fe316fa-a2e6-427c-9ddc-41e24f9fa911	0f6a77b3-b0c1-420a-943d-2ca4b161991d	745820cf-14e3-4837-be8a-2f7151ec9131
f66f2eff-b3f5-418c-be03-d46388ade8d7	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	220672be-7563-4b84-83f0-cbd497765462
67544da4-3ed3-454f-aa6c-3a6c59b11fcb	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	d1dbec9d-ce36-42b3-a467-0b1512f41545
c09b903b-d190-4c6d-b84e-8d3d3d93c2f2	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	f3c04916-f30d-4360-b465-c5eb262dce94
f984b223-87a1-4887-a3fd-0690b1a26676	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	f3c04916-f30d-4360-b465-c5eb262dce94
c61e105a-4b85-4242-b890-7804be87d11f	f3c04916-f30d-4360-b465-c5eb262dce94	4ac4c910-d783-48d5-ae41-b542e8cb666f
2c7725ce-8ab6-4aeb-a9a3-051ef5901b59	2bdf8bc5-7def-47aa-94ca-7f298307ab35	b0ed894a-610d-498c-b11f-ed47d2a87b29
8bb0abb2-b86b-4cef-a6c6-61577320b3d4	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
5e85748a-f5ec-4817-88c6-da61c65dd3bb	f927fc08-8f8a-4a0b-adec-d924091dcad1	2bebe474-6406-409e-904c-ff7865ac755e
d6850c86-c941-4e84-89c5-48c4db0e4a30	220672be-7563-4b84-83f0-cbd497765462	cd3675d5-61d6-4adf-96d8-bb5867342208
e000fb52-9ce5-4d38-bb83-8fe35e0e1517	f927fc08-8f8a-4a0b-adec-d924091dcad1	04b123c0-c2ed-464f-b848-5637bbd7d89d
918c934f-aa70-4674-b383-931fb2fe491a	04b123c0-c2ed-464f-b848-5637bbd7d89d	cd3675d5-61d6-4adf-96d8-bb5867342208
058864b8-fdc4-4d9e-a033-d0e1e5b82d7a	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	f3c04916-f30d-4360-b465-c5eb262dce94
7a6e549b-f4a2-4ffd-9cf0-abd1e7db1225	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	7575e78a-a78b-4900-9fb3-b30c925e5f89
3309317f-3778-4050-8708-f1db4b243f0f	f927fc08-8f8a-4a0b-adec-d924091dcad1	7575e78a-a78b-4900-9fb3-b30c925e5f89
fa5f9bcb-1533-4398-b5a0-9fb2cc72c950	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
e15267bb-b3b8-4417-84aa-1b6f11d40277	2bdba617-734f-48a5-844c-c7ca5a68781b	6a766343-b2eb-491f-8abb-ac90dd69fa95
dc39b7b2-d5d9-447e-9948-1123e40bf665	a96df0df-f4a1-4d82-a655-2f7f94ace896	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
d374a144-6185-4ce0-8bb3-fca0de9b1930	2bdf8bc5-7def-47aa-94ca-7f298307ab35	745820cf-14e3-4837-be8a-2f7151ec9131
75be8843-f774-4ccc-8e10-5813bc018fb9	960823cf-d908-4246-8fa0-0ac6118797ca	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
2ee69b41-b1a1-4be7-94db-aa375f8e8ee5	6a766343-b2eb-491f-8abb-ac90dd69fa95	a96df0df-f4a1-4d82-a655-2f7f94ace896
780db089-065c-4484-bead-01d124b6e28d	2bebe474-6406-409e-904c-ff7865ac755e	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
3451faf6-f395-41de-8f39-d73f269ad4b0	b0ed894a-610d-498c-b11f-ed47d2a87b29	d1ec15b3-32ad-42af-b82b-32e4ccccca84
f9d92cec-259f-42b7-816a-659bd83a2fad	9e00a085-1e03-4bb5-b18d-65d93f16f743	4ac4c910-d783-48d5-ae41-b542e8cb666f
5a2830d0-9e4f-4895-b83e-05d785564ff5	31c3d5b3-8c7c-4cef-a037-2eccb1839791	6a766343-b2eb-491f-8abb-ac90dd69fa95
d72e9032-29b1-4701-8ad4-880b56869d05	a96df0df-f4a1-4d82-a655-2f7f94ace896	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
417aa5f5-9fce-49d5-84cf-be6169cee2b7	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
043dbabe-27bd-49d1-938f-9de26a65debd	16eca672-7fea-4e30-a715-4aaac96518ce	0f6a77b3-b0c1-420a-943d-2ca4b161991d
f45bb468-12e8-4b97-9229-fab97a5e4da2	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	64d12d2a-f5a9-4109-b79f-561e15f878b6
bc505700-46e9-43ba-b9a3-971c8e1a44ce	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	31c3d5b3-8c7c-4cef-a037-2eccb1839791
3e95dd21-1ee8-451c-a0bc-fc8933c7f6bc	220672be-7563-4b84-83f0-cbd497765462	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
7cc22f20-30be-4f21-9a2c-1d27dfe4a76c	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	a96df0df-f4a1-4d82-a655-2f7f94ace896
9b6a42be-c757-451c-8c87-cfe565f3b66e	d1dbec9d-ce36-42b3-a467-0b1512f41545	960823cf-d908-4246-8fa0-0ac6118797ca
cba0ecc1-b5a7-44dd-8573-e61f83b6afba	6a766343-b2eb-491f-8abb-ac90dd69fa95	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
f605b7fb-f7c5-4b4b-9e77-9e4c620907d1	f927fc08-8f8a-4a0b-adec-d924091dcad1	0f6a77b3-b0c1-420a-943d-2ca4b161991d
f92b9f64-7256-4ad1-9f5c-11fe33907647	d1dbec9d-ce36-42b3-a467-0b1512f41545	645dce1e-7159-4b1b-86f0-0bc601f77b4a
bd6685b3-3fe4-494a-bdf6-8dfb750e0d21	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	2bebe474-6406-409e-904c-ff7865ac755e
5d946c7d-ee56-46ac-8eaf-1f502af6043b	d1dbec9d-ce36-42b3-a467-0b1512f41545	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
75874b0d-ba83-413e-bb01-16f5ff5e2217	4ac4c910-d783-48d5-ae41-b542e8cb666f	04b123c0-c2ed-464f-b848-5637bbd7d89d
e3b9ea9a-3194-4e90-ab39-3abf6221c216	cd3675d5-61d6-4adf-96d8-bb5867342208	220672be-7563-4b84-83f0-cbd497765462
9acea3cd-4ff0-4b70-bb51-c5baa2cc55b6	9e00a085-1e03-4bb5-b18d-65d93f16f743	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
a112735e-44ac-4006-b5f5-12d996212bac	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	9e00a085-1e03-4bb5-b18d-65d93f16f743
c4ce26f3-3ffa-495d-95c3-ca64f1a4e3a2	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
20159288-6132-4047-b5f0-7129fe5ef026	5d1b295d-a018-49a2-9c53-a639a3bf51ef	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
e2a82424-b17b-4157-8e67-1847e9b4b1b1	b0afe2ef-0b3d-481d-9654-f9e67207757d	0f6a77b3-b0c1-420a-943d-2ca4b161991d
d9da9eaf-bb27-4cc5-8dde-71619531d196	b0ed894a-610d-498c-b11f-ed47d2a87b29	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
044c55bd-761f-4b7e-9fb7-72cb651175a0	cd3675d5-61d6-4adf-96d8-bb5867342208	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
ae7d7f22-550f-4e61-a849-8c8cfb2a64bd	5d1b295d-a018-49a2-9c53-a639a3bf51ef	a9b20768-6469-4d39-b0aa-c4ed19ae9897
73a6769c-2be7-4798-b3b1-c152652b9cb9	693dab47-5108-490b-9a10-97ff75796112	2bdba617-734f-48a5-844c-c7ca5a68781b
f7960058-6919-4660-84b3-e1bdcf5bd328	a9b20768-6469-4d39-b0aa-c4ed19ae9897	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
8c67d4e4-40a9-4df0-965b-865b5ae23397	a96df0df-f4a1-4d82-a655-2f7f94ace896	6a766343-b2eb-491f-8abb-ac90dd69fa95
3f65673c-cb80-4657-99a8-47dced5ef304	693dab47-5108-490b-9a10-97ff75796112	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
54426419-63b6-436b-93cb-d70cd0aeb197	cd3675d5-61d6-4adf-96d8-bb5867342208	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
01aaa6cb-7a0e-4132-a51e-b0dba41c0c6d	9e00a085-1e03-4bb5-b18d-65d93f16f743	04b123c0-c2ed-464f-b848-5637bbd7d89d
f013c48c-295c-4a17-a045-1b99ddb10a6b	745820cf-14e3-4837-be8a-2f7151ec9131	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
2ff20876-7969-4ab9-a8f2-a6c7df0c89fe	7575e78a-a78b-4900-9fb3-b30c925e5f89	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
50833116-d38b-40ef-858a-7d7a37cb9669	2bdf8bc5-7def-47aa-94ca-7f298307ab35	7d2d10ef-c751-4b4c-aff4-8f47c9952491
08bdebfc-e15a-43fd-bdde-ec789c98f404	c02fcc25-b9f3-4473-bf1a-80abbdc73474	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
ccbd1115-cf12-45a8-ba4e-b911b8598f5a	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	d1ec15b3-32ad-42af-b82b-32e4ccccca84
8612c685-68aa-4737-991f-21d6de4e10d3	04b123c0-c2ed-464f-b848-5637bbd7d89d	9e00a085-1e03-4bb5-b18d-65d93f16f743
e0278434-3560-42d8-87da-c82c47448890	2bebe474-6406-409e-904c-ff7865ac755e	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
d678bec2-e827-4777-98a9-f91fb92f2bec	04b123c0-c2ed-464f-b848-5637bbd7d89d	a96df0df-f4a1-4d82-a655-2f7f94ace896
8bf323cc-15ca-40d7-9ada-b57d8e58ebd5	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	2bdf8bc5-7def-47aa-94ca-7f298307ab35
e718bdde-a4f9-4620-b2e2-e24bba1c263e	c02fcc25-b9f3-4473-bf1a-80abbdc73474	16eca672-7fea-4e30-a715-4aaac96518ce
89c31be9-096f-4708-b52f-23f60110fb99	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	4ac4c910-d783-48d5-ae41-b542e8cb666f
bb06ee42-2fa3-4d33-a0e5-ef397370a323	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	f2d14b9e-18a1-4479-a5da-835c7443586f
93c96045-afd6-4fc7-9142-1c9077e711b7	7d2d10ef-c751-4b4c-aff4-8f47c9952491	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
cde45715-5537-4dde-8966-a021ab6aac17	2bdba617-734f-48a5-844c-c7ca5a68781b	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
72676332-24dc-44cf-84cc-e0598a0ee788	64d12d2a-f5a9-4109-b79f-561e15f878b6	9e00a085-1e03-4bb5-b18d-65d93f16f743
380249be-54f5-4900-aa6e-31e6d29f48e2	f2d14b9e-18a1-4479-a5da-835c7443586f	6a766343-b2eb-491f-8abb-ac90dd69fa95
747a18b3-652d-44d1-9f37-9667ddff2b59	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	2bdf8bc5-7def-47aa-94ca-7f298307ab35
daa38c33-735a-4b74-b2f8-51daf6edbc44	d1ec15b3-32ad-42af-b82b-32e4ccccca84	4ac4c910-d783-48d5-ae41-b542e8cb666f
a7b494f7-65f3-4f38-90f5-1106bc0cc3a3	a96df0df-f4a1-4d82-a655-2f7f94ace896	64d12d2a-f5a9-4109-b79f-561e15f878b6
867884da-12c4-403a-ad99-c2806187023a	4ac4c910-d783-48d5-ae41-b542e8cb666f	2bdba617-734f-48a5-844c-c7ca5a68781b
17dcc8dd-d2df-44c0-9bdf-ddce05c3c88f	d1ec15b3-32ad-42af-b82b-32e4ccccca84	0f6a77b3-b0c1-420a-943d-2ca4b161991d
c936bfa6-ca6e-468d-8464-569337e5ed6e	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	960823cf-d908-4246-8fa0-0ac6118797ca
0b26e75a-e312-4d7d-8256-7a8c5fd41b4d	16eca672-7fea-4e30-a715-4aaac96518ce	960823cf-d908-4246-8fa0-0ac6118797ca
0efdf981-fce2-4caa-8cde-f68b77f637c0	645dce1e-7159-4b1b-86f0-0bc601f77b4a	0f6a77b3-b0c1-420a-943d-2ca4b161991d
c71d16a7-b8f3-4291-bfe0-24c5ac21ff5d	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	9e00a085-1e03-4bb5-b18d-65d93f16f743
3e4f332b-c175-4261-96a2-a89c24a566e7	d1ec15b3-32ad-42af-b82b-32e4ccccca84	5d1b295d-a018-49a2-9c53-a639a3bf51ef
16e803bc-82be-429e-89f7-e0cb15f7aee9	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	b0afe2ef-0b3d-481d-9654-f9e67207757d
84d98c0a-d9ad-42d4-a13d-ffce690d061a	b0ed894a-610d-498c-b11f-ed47d2a87b29	f2d14b9e-18a1-4479-a5da-835c7443586f
5c8a8dfa-c4de-436e-8b8e-72bb1f24454a	645dce1e-7159-4b1b-86f0-0bc601f77b4a	7d2d10ef-c751-4b4c-aff4-8f47c9952491
91a12aaa-a265-4bbc-9147-af55e53b29df	0f6a77b3-b0c1-420a-943d-2ca4b161991d	16eca672-7fea-4e30-a715-4aaac96518ce
ea1bfb79-a811-45aa-b459-600c7072e7ea	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	6a766343-b2eb-491f-8abb-ac90dd69fa95
2c0eb2ca-39e1-4de6-9ca2-5a7775c1fad3	b0ed894a-610d-498c-b11f-ed47d2a87b29	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
13c46b65-c20c-4035-8b7e-65e3bff7069c	04b123c0-c2ed-464f-b848-5637bbd7d89d	645dce1e-7159-4b1b-86f0-0bc601f77b4a
377d3fa3-94f9-4c43-8b2f-82f4d7f5165b	b0ed894a-610d-498c-b11f-ed47d2a87b29	6a766343-b2eb-491f-8abb-ac90dd69fa95
7a5ed064-1e52-4043-bb6f-1c82b9cf6b2a	cd3675d5-61d6-4adf-96d8-bb5867342208	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
6f3f6c18-c8a6-488c-bf31-5ce776007f7a	d9500d74-9405-4bb6-89b9-6b19147f2cc8	645dce1e-7159-4b1b-86f0-0bc601f77b4a
70889625-4afe-48c3-b4da-5a82eb5326da	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	c02fcc25-b9f3-4473-bf1a-80abbdc73474
28c90d74-8835-4b1f-a8a6-a14e694f6689	f2d14b9e-18a1-4479-a5da-835c7443586f	4ac4c910-d783-48d5-ae41-b542e8cb666f
d1d51ca4-bbee-432a-94ac-c719dae16214	f2d14b9e-18a1-4479-a5da-835c7443586f	b0ed894a-610d-498c-b11f-ed47d2a87b29
b98f3462-24ed-4457-859c-a82cabc160a8	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	c02fcc25-b9f3-4473-bf1a-80abbdc73474
d9b15872-07b8-437e-a17b-89f57c11fe3f	a9b20768-6469-4d39-b0aa-c4ed19ae9897	04b123c0-c2ed-464f-b848-5637bbd7d89d
37fec701-2c6b-41a4-824c-aa715479a438	a96df0df-f4a1-4d82-a655-2f7f94ace896	9e00a085-1e03-4bb5-b18d-65d93f16f743
72f5cfd4-8695-4829-810c-cdc0838d4450	d9500d74-9405-4bb6-89b9-6b19147f2cc8	d1ec15b3-32ad-42af-b82b-32e4ccccca84
b3e8a1ae-eb46-4690-89d1-baace06a6132	c02fcc25-b9f3-4473-bf1a-80abbdc73474	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
ce2382d9-c315-4b48-9b45-d6840108ec53	2bdf8bc5-7def-47aa-94ca-7f298307ab35	220672be-7563-4b84-83f0-cbd497765462
dda63cda-8172-4090-9988-de13980fff05	220672be-7563-4b84-83f0-cbd497765462	31c3d5b3-8c7c-4cef-a037-2eccb1839791
2f02c548-3fe4-4851-b5ae-d50f83733c6e	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	04b123c0-c2ed-464f-b848-5637bbd7d89d
2151aefc-0878-48f6-9c28-94b0233d5e6e	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	693dab47-5108-490b-9a10-97ff75796112
c8b71c8b-54f4-4285-af4c-1298a258320d	a96df0df-f4a1-4d82-a655-2f7f94ace896	d1dbec9d-ce36-42b3-a467-0b1512f41545
1ece969b-66e3-4fc9-b350-8bafa5be3bd3	64d12d2a-f5a9-4109-b79f-561e15f878b6	16eca672-7fea-4e30-a715-4aaac96518ce
ef9e273e-caac-43f4-b7aa-f14e839deb4d	5d1b295d-a018-49a2-9c53-a639a3bf51ef	b0afe2ef-0b3d-481d-9654-f9e67207757d
f8687cad-be92-46ea-ab54-80bdcdca71a4	2bebe474-6406-409e-904c-ff7865ac755e	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
e2e68230-7be6-4516-87ab-c56131579987	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	64d12d2a-f5a9-4109-b79f-561e15f878b6
3330819f-3ece-4716-a9d2-2d8252ff3d16	f2d14b9e-18a1-4479-a5da-835c7443586f	0f6a77b3-b0c1-420a-943d-2ca4b161991d
9e97b83b-c47c-4332-aee1-fdcfdd18efdc	693dab47-5108-490b-9a10-97ff75796112	d1dbec9d-ce36-42b3-a467-0b1512f41545
1c0bc16e-9eeb-4714-abc2-7054d68759ed	f2d14b9e-18a1-4479-a5da-835c7443586f	a9b20768-6469-4d39-b0aa-c4ed19ae9897
12aefac5-424a-4a41-b087-4c1ddd39803c	220672be-7563-4b84-83f0-cbd497765462	693dab47-5108-490b-9a10-97ff75796112
73859e09-bc74-4d54-a397-c15d1f4ca2f6	220672be-7563-4b84-83f0-cbd497765462	2bebe474-6406-409e-904c-ff7865ac755e
b1f25372-d2c0-453d-a033-5622424fc6a8	c02fcc25-b9f3-4473-bf1a-80abbdc73474	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
0713e8ff-064c-4df7-966c-382fa704206d	693dab47-5108-490b-9a10-97ff75796112	645dce1e-7159-4b1b-86f0-0bc601f77b4a
7e93f83f-4660-4d8f-9c3b-74eec6d886a7	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	0f6a77b3-b0c1-420a-943d-2ca4b161991d
4c05f3bb-d34e-4f28-bc8d-0fc25bf7461c	693dab47-5108-490b-9a10-97ff75796112	4ac4c910-d783-48d5-ae41-b542e8cb666f
c2658d8d-4d01-4ac5-9dae-062408a061f3	16eca672-7fea-4e30-a715-4aaac96518ce	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
b0517171-dd6e-4a55-b2f4-5202d8f2703a	04b123c0-c2ed-464f-b848-5637bbd7d89d	0f6a77b3-b0c1-420a-943d-2ca4b161991d
a47fb946-5117-4858-aea9-f9a9bed7c631	d1ec15b3-32ad-42af-b82b-32e4ccccca84	f927fc08-8f8a-4a0b-adec-d924091dcad1
ea9700b9-8c24-4c65-ac01-e3c94d0cbd29	04b123c0-c2ed-464f-b848-5637bbd7d89d	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
1ab3179e-0f5c-46c1-8302-43ecb9eb35a4	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
90e384a3-4dbc-4c4e-98a7-629466dd12d0	d1dbec9d-ce36-42b3-a467-0b1512f41545	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
64f51dda-400e-4bdb-85fa-0ba4f89f49a0	4ac4c910-d783-48d5-ae41-b542e8cb666f	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
34cbdfa0-f571-41cb-a1a4-d0347827f448	b0ed894a-610d-498c-b11f-ed47d2a87b29	7d2d10ef-c751-4b4c-aff4-8f47c9952491
0de2fdec-6c38-4469-9f1f-f913588be2d4	16eca672-7fea-4e30-a715-4aaac96518ce	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
cf1ed4ab-853a-4b0c-bb73-170417999a3d	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	6a766343-b2eb-491f-8abb-ac90dd69fa95
4998c908-e3c4-466d-b9cc-1ad39f37df8c	745820cf-14e3-4837-be8a-2f7151ec9131	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
bc90ca73-80ee-49db-80f3-91d5ac331bf5	9e00a085-1e03-4bb5-b18d-65d93f16f743	31c3d5b3-8c7c-4cef-a037-2eccb1839791
edd5002a-c78a-4ab8-8e94-269a5d0127a0	0f6a77b3-b0c1-420a-943d-2ca4b161991d	693dab47-5108-490b-9a10-97ff75796112
785336d2-1996-4aa2-9b62-41a2b66cbff7	7575e78a-a78b-4900-9fb3-b30c925e5f89	cd3675d5-61d6-4adf-96d8-bb5867342208
97d57640-0db6-47e3-a191-0f30862ff57c	2bebe474-6406-409e-904c-ff7865ac755e	a96df0df-f4a1-4d82-a655-2f7f94ace896
8d8b94ed-9ce2-41de-ae20-cd6b4a07581a	d1dbec9d-ce36-42b3-a467-0b1512f41545	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
d352d755-2f94-45c6-83de-3b694ee915ab	9e00a085-1e03-4bb5-b18d-65d93f16f743	b0ed894a-610d-498c-b11f-ed47d2a87b29
9a59b799-7e3f-4ae1-9727-9e44992229f3	7d2d10ef-c751-4b4c-aff4-8f47c9952491	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
3e4080b8-d025-4a41-bff9-51afcb913650	2bdba617-734f-48a5-844c-c7ca5a68781b	a96df0df-f4a1-4d82-a655-2f7f94ace896
9edb9082-4e36-4598-b6fd-320541316873	960823cf-d908-4246-8fa0-0ac6118797ca	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
23cd1383-f9ef-492f-a132-d221f2128243	5d1b295d-a018-49a2-9c53-a639a3bf51ef	b0ed894a-610d-498c-b11f-ed47d2a87b29
23f0a6b5-6de2-41f2-b409-a094e9b76716	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
da2a77bd-ddcf-437e-ae71-3105fc6e0086	16eca672-7fea-4e30-a715-4aaac96518ce	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
0c82e45e-3af3-480c-90ee-0ee0cb4552d0	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
6a49337b-bca2-43fa-8404-6d9146486b11	b0ed894a-610d-498c-b11f-ed47d2a87b29	0f6a77b3-b0c1-420a-943d-2ca4b161991d
4e8aa16f-e0cf-4566-84c0-17b702ca14f7	a9b20768-6469-4d39-b0aa-c4ed19ae9897	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
dc3be492-7f51-42a8-861e-f4b86e563420	f2d14b9e-18a1-4479-a5da-835c7443586f	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
663fa1e6-7b09-4caf-ae70-eb2bb60a7a8f	d9500d74-9405-4bb6-89b9-6b19147f2cc8	960823cf-d908-4246-8fa0-0ac6118797ca
29b4db5c-8e74-4f08-9005-6ba6f1988e95	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	9e00a085-1e03-4bb5-b18d-65d93f16f743
028c5957-c603-423e-8d12-8ff32bc05603	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	220672be-7563-4b84-83f0-cbd497765462
9e8ae2a0-2601-4be5-b208-b197e27a6116	0f6a77b3-b0c1-420a-943d-2ca4b161991d	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
408c6bb5-0210-414f-8dc5-3426b48f23ee	645dce1e-7159-4b1b-86f0-0bc601f77b4a	b0ed894a-610d-498c-b11f-ed47d2a87b29
75c4e887-631b-464c-8c37-c2fe8f248e72	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	220672be-7563-4b84-83f0-cbd497765462
906ba3e0-bb0f-487f-9c37-78c4f1a5c9db	0f6a77b3-b0c1-420a-943d-2ca4b161991d	7575e78a-a78b-4900-9fb3-b30c925e5f89
ffde45ba-25df-4cc1-a729-264b7d073fd1	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	745820cf-14e3-4837-be8a-2f7151ec9131
47d37157-0f05-41c1-a1a7-09b63567f110	7d2d10ef-c751-4b4c-aff4-8f47c9952491	f2d14b9e-18a1-4479-a5da-835c7443586f
224e64b9-db6e-4fd9-9dc4-d607755ee9c8	c02fcc25-b9f3-4473-bf1a-80abbdc73474	9e00a085-1e03-4bb5-b18d-65d93f16f743
79a91623-9b2a-47f9-9faa-cce1af241481	d1ec15b3-32ad-42af-b82b-32e4ccccca84	745820cf-14e3-4837-be8a-2f7151ec9131
96973ee0-ec60-4fa0-8da9-38faf72550f7	4ac4c910-d783-48d5-ae41-b542e8cb666f	7575e78a-a78b-4900-9fb3-b30c925e5f89
58febf1e-6597-45b9-af06-25d144b5438c	0f6a77b3-b0c1-420a-943d-2ca4b161991d	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
44d2f600-a7a0-4066-880d-962d822b5457	c02fcc25-b9f3-4473-bf1a-80abbdc73474	b0ed894a-610d-498c-b11f-ed47d2a87b29
f4f5d7da-8a0a-4014-b1df-074e5d7f3ab6	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	693dab47-5108-490b-9a10-97ff75796112
12533043-28a3-4998-8f21-dc99ab9a18d9	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	cd3675d5-61d6-4adf-96d8-bb5867342208
7ae9b278-d210-45ef-832c-e6a11264f09a	b0afe2ef-0b3d-481d-9654-f9e67207757d	a9b20768-6469-4d39-b0aa-c4ed19ae9897
07abf617-bea5-4cb9-9d1c-09ae5e8bfe14	0f6a77b3-b0c1-420a-943d-2ca4b161991d	7d2d10ef-c751-4b4c-aff4-8f47c9952491
d2d82b48-4f14-4392-b195-ef5da4a05568	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	d9500d74-9405-4bb6-89b9-6b19147f2cc8
efed5909-fcec-4022-a17d-536ccb0a2050	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	9623ff85-67b1-4f4d-8b48-1544c3cb38ab
a1df9098-3ce6-4032-b040-5fb87f65615b	745820cf-14e3-4837-be8a-2f7151ec9131	04b123c0-c2ed-464f-b848-5637bbd7d89d
282bea23-20aa-4893-8043-b2cbe770a23d	960823cf-d908-4246-8fa0-0ac6118797ca	7d2d10ef-c751-4b4c-aff4-8f47c9952491
62ff8613-46d9-4aec-9c77-9ebd1d8ce9a6	c02fcc25-b9f3-4473-bf1a-80abbdc73474	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
5428e8ec-011a-4557-bffc-44dc26b408cd	b0ed894a-610d-498c-b11f-ed47d2a87b29	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
435b4eba-9287-484d-ba62-ac5821020f81	16eca672-7fea-4e30-a715-4aaac96518ce	d1dbec9d-ce36-42b3-a467-0b1512f41545
86ce8fd7-9c4b-4164-9482-57ae895cc186	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	645dce1e-7159-4b1b-86f0-0bc601f77b4a
9591544a-e781-4931-8387-9dfb964cd026	d1dbec9d-ce36-42b3-a467-0b1512f41545	31c3d5b3-8c7c-4cef-a037-2eccb1839791
d2ac9e3d-a494-4e51-bcf8-1f0e955cd316	2bebe474-6406-409e-904c-ff7865ac755e	cd3675d5-61d6-4adf-96d8-bb5867342208
e9194513-d318-4438-97cc-25a3b7029da8	16eca672-7fea-4e30-a715-4aaac96518ce	7575e78a-a78b-4900-9fb3-b30c925e5f89
c3e5fdc6-4904-42d1-88b5-3ebe06325d87	a96df0df-f4a1-4d82-a655-2f7f94ace896	2bebe474-6406-409e-904c-ff7865ac755e
46ea5e7a-ca5d-4a51-a2ff-795e3ec96f27	2bebe474-6406-409e-904c-ff7865ac755e	745820cf-14e3-4837-be8a-2f7151ec9131
4d8e7220-efba-4445-b221-54fb20323ad5	31c3d5b3-8c7c-4cef-a037-2eccb1839791	220672be-7563-4b84-83f0-cbd497765462
6c673561-afb7-44ac-85ff-a12b16923840	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	693dab47-5108-490b-9a10-97ff75796112
e7ce8459-1e85-417e-8dcb-b5fa912480ec	a96df0df-f4a1-4d82-a655-2f7f94ace896	7575e78a-a78b-4900-9fb3-b30c925e5f89
783454e0-e74c-4828-9776-baf04cb17802	c02fcc25-b9f3-4473-bf1a-80abbdc73474	b0afe2ef-0b3d-481d-9654-f9e67207757d
be1036f3-0b67-42ec-b426-a9d7e8547b33	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
915b3069-d2b1-41db-abf1-b34e22270c9e	d1ec15b3-32ad-42af-b82b-32e4ccccca84	220672be-7563-4b84-83f0-cbd497765462
b45cbde3-b001-4b6c-a24a-10a8a5a5a4be	7d2d10ef-c751-4b4c-aff4-8f47c9952491	04b123c0-c2ed-464f-b848-5637bbd7d89d
e3bb6978-729c-4d1c-ad21-f92c3bd31ce7	b0afe2ef-0b3d-481d-9654-f9e67207757d	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
e7f169c8-62de-41c8-91ce-5522fce5cf5f	d1ec15b3-32ad-42af-b82b-32e4ccccca84	31c3d5b3-8c7c-4cef-a037-2eccb1839791
a0b92390-b3b0-49db-aed1-1449ccac6469	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
bf1b49b3-2048-411e-8c24-76d79792bfa4	16eca672-7fea-4e30-a715-4aaac96518ce	5d1b295d-a018-49a2-9c53-a639a3bf51ef
ac83dd9e-1599-442c-9241-2d63d964e2b2	2bebe474-6406-409e-904c-ff7865ac755e	220672be-7563-4b84-83f0-cbd497765462
7eb694a4-b90e-4f3c-9152-ff21cd8c6df5	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	d1ec15b3-32ad-42af-b82b-32e4ccccca84
7d1c72d0-aa89-4520-b441-405055a9485d	a9b20768-6469-4d39-b0aa-c4ed19ae9897	220672be-7563-4b84-83f0-cbd497765462
f0497e09-d775-40d1-bb34-8e1bb60792f1	693dab47-5108-490b-9a10-97ff75796112	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
fdd6f3df-654f-45e0-82fa-d9b8f3ed9605	b0ed894a-610d-498c-b11f-ed47d2a87b29	04b123c0-c2ed-464f-b848-5637bbd7d89d
f9703e24-9eea-4e7b-b665-469079b753a6	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	693dab47-5108-490b-9a10-97ff75796112
8f25f683-6202-4717-a6f9-5449631b6475	04b123c0-c2ed-464f-b848-5637bbd7d89d	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
6e3ba437-a825-4d0c-9a0f-4e41d59df58d	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
90933284-e327-4a5b-ad9c-9bfea464ac50	f3c04916-f30d-4360-b465-c5eb262dce94	2bebe474-6406-409e-904c-ff7865ac755e
12f3c3f9-a7a5-43d9-aab7-b175365a5fff	d1dbec9d-ce36-42b3-a467-0b1512f41545	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
da9a3bed-1c55-43d5-ab80-b3518dd0d6f2	64d12d2a-f5a9-4109-b79f-561e15f878b6	d1ec15b3-32ad-42af-b82b-32e4ccccca84
64f938ad-6b08-49b7-8077-87eb27c20ace	f3c04916-f30d-4360-b465-c5eb262dce94	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
c292a9db-66b6-40d7-bfc0-17ec7630a0ab	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	16eca672-7fea-4e30-a715-4aaac96518ce
511f1836-8903-4845-b850-56c2c81a0d96	2bdba617-734f-48a5-844c-c7ca5a68781b	d1dbec9d-ce36-42b3-a467-0b1512f41545
2c95aeb2-a254-471c-bbe0-8ed068efc11f	693dab47-5108-490b-9a10-97ff75796112	b0ed894a-610d-498c-b11f-ed47d2a87b29
61867240-143d-4c99-9733-b36385a3aa58	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
5bc79334-0f6e-4871-b3ea-4e9039cad6dc	d1dbec9d-ce36-42b3-a467-0b1512f41545	0f6a77b3-b0c1-420a-943d-2ca4b161991d
c03de4dc-670c-4da4-bfc6-46f11ae4717c	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	16eca672-7fea-4e30-a715-4aaac96518ce
65134af0-c947-44c0-8bd4-dafe27a06e50	2bdba617-734f-48a5-844c-c7ca5a68781b	693dab47-5108-490b-9a10-97ff75796112
6d876b8d-f3f3-4020-922c-351019778ffb	7d2d10ef-c751-4b4c-aff4-8f47c9952491	f927fc08-8f8a-4a0b-adec-d924091dcad1
51abbdbd-5be1-45fd-a886-a17228378d3a	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	31c3d5b3-8c7c-4cef-a037-2eccb1839791
a514b50a-4202-40c2-9225-1c4ca50896c4	c02fcc25-b9f3-4473-bf1a-80abbdc73474	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
0827aa67-ee1f-4024-a824-9c168d1b2f7b	960823cf-d908-4246-8fa0-0ac6118797ca	693dab47-5108-490b-9a10-97ff75796112
0473bcff-23cf-4e37-a000-eb05c8e2966a	a9b20768-6469-4d39-b0aa-c4ed19ae9897	2bdba617-734f-48a5-844c-c7ca5a68781b
42e00993-f680-4323-a5ce-a0677b198f06	c02fcc25-b9f3-4473-bf1a-80abbdc73474	a96df0df-f4a1-4d82-a655-2f7f94ace896
7d6502b1-4e7b-4462-bb4b-9309dd9a669f	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	f927fc08-8f8a-4a0b-adec-d924091dcad1
bda3007a-a991-4377-87e4-ec00071328a4	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	5d1b295d-a018-49a2-9c53-a639a3bf51ef
c29c9532-999f-47ad-9195-d9d1c95fec6b	c02fcc25-b9f3-4473-bf1a-80abbdc73474	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
9a0b70bf-71e5-4bd3-9f1c-af0417bfcfa2	c02fcc25-b9f3-4473-bf1a-80abbdc73474	31c3d5b3-8c7c-4cef-a037-2eccb1839791
b6c66369-7fdf-4b40-aeb7-062555a2f258	5d1b295d-a018-49a2-9c53-a639a3bf51ef	960823cf-d908-4246-8fa0-0ac6118797ca
6009e2dc-88e3-4809-957e-eeb167111744	d1dbec9d-ce36-42b3-a467-0b1512f41545	6a766343-b2eb-491f-8abb-ac90dd69fa95
7f223899-9186-45c4-b2b9-799405af8033	a9b20768-6469-4d39-b0aa-c4ed19ae9897	b0afe2ef-0b3d-481d-9654-f9e67207757d
2c479495-10e0-4dd7-9049-a70a3c441ed9	16eca672-7fea-4e30-a715-4aaac96518ce	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
b800e6f3-f8ad-4155-b63b-30259b240586	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	2bebe474-6406-409e-904c-ff7865ac755e
bfe8e32f-1f85-4b8b-b558-ceea28d93fde	7575e78a-a78b-4900-9fb3-b30c925e5f89	d1ec15b3-32ad-42af-b82b-32e4ccccca84
6a3ef6f9-4c97-4fa3-8807-47e1ac7faf7d	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	2bebe474-6406-409e-904c-ff7865ac755e
653c2fa4-9fa5-4caf-8aab-155933ce58e9	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	f3c04916-f30d-4360-b465-c5eb262dce94
0007cafb-c327-4da8-bbc4-d8c4eb0b78d1	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	d1ec15b3-32ad-42af-b82b-32e4ccccca84
eb1efba1-5f79-47ee-b4a6-80b1d541ce13	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	6a766343-b2eb-491f-8abb-ac90dd69fa95
7e0d2d67-3209-4d03-adec-00c4de1f0666	b0ed894a-610d-498c-b11f-ed47d2a87b29	16eca672-7fea-4e30-a715-4aaac96518ce
23578afe-2f8a-4cf1-9219-169141032551	f2d14b9e-18a1-4479-a5da-835c7443586f	a96df0df-f4a1-4d82-a655-2f7f94ace896
96b2a81b-e218-4106-a9bd-5910fb0fbc12	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	9e00a085-1e03-4bb5-b18d-65d93f16f743
4303499a-8fc2-4cfb-bcb7-2ebbc1212b97	2bdba617-734f-48a5-844c-c7ca5a68781b	0f6a77b3-b0c1-420a-943d-2ca4b161991d
e4b661f1-ea3a-4061-bea9-558f5f6e4650	31c3d5b3-8c7c-4cef-a037-2eccb1839791	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
6a57f50b-1117-4cd7-984c-6e11b9967d9f	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	b0afe2ef-0b3d-481d-9654-f9e67207757d
aeaabc7b-3cf0-4f23-974c-f8377bc7dc8f	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	5d1b295d-a018-49a2-9c53-a639a3bf51ef
ad1c204b-c699-44ca-a0aa-bca7489fb6e2	d9500d74-9405-4bb6-89b9-6b19147f2cc8	b0afe2ef-0b3d-481d-9654-f9e67207757d
d9a84b69-6850-4777-8ad7-daf78e2af23d	31c3d5b3-8c7c-4cef-a037-2eccb1839791	16eca672-7fea-4e30-a715-4aaac96518ce
ce345810-2d6b-4c22-9299-a4796b2b954f	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	7d2d10ef-c751-4b4c-aff4-8f47c9952491
027c6761-e3b7-420f-920a-ff8d0282c8bc	7d2d10ef-c751-4b4c-aff4-8f47c9952491	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
ecbb1d40-0535-4b38-b76e-83fa14cb54b1	d9500d74-9405-4bb6-89b9-6b19147f2cc8	2bebe474-6406-409e-904c-ff7865ac755e
0dfafb55-12be-42ae-8b37-104c80614623	645dce1e-7159-4b1b-86f0-0bc601f77b4a	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
224e965e-7f1d-4dc9-ac77-7ecb42707cc6	0f6a77b3-b0c1-420a-943d-2ca4b161991d	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
2e52a4ec-a888-4b48-99a2-2496261deffb	b0ed894a-610d-498c-b11f-ed47d2a87b29	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
076d9cd2-7b73-4acc-ae5e-249e01d56900	31c3d5b3-8c7c-4cef-a037-2eccb1839791	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
a490d360-1cde-4682-8cfc-694f6e7efe72	7d2d10ef-c751-4b4c-aff4-8f47c9952491	d1ec15b3-32ad-42af-b82b-32e4ccccca84
13450382-47b8-4917-bc35-9c67b0151328	b0afe2ef-0b3d-481d-9654-f9e67207757d	5d1b295d-a018-49a2-9c53-a639a3bf51ef
27c9fdda-f307-43b0-a70c-2ad75bb5cd28	a9b20768-6469-4d39-b0aa-c4ed19ae9897	4ac4c910-d783-48d5-ae41-b542e8cb666f
ed4c2554-afd1-4da9-89bd-ebdce598a1c5	64d12d2a-f5a9-4109-b79f-561e15f878b6	4ac4c910-d783-48d5-ae41-b542e8cb666f
de62b43e-310d-4d7f-8441-8935cd652d06	7d2d10ef-c751-4b4c-aff4-8f47c9952491	b0afe2ef-0b3d-481d-9654-f9e67207757d
78bec90d-f6a0-42ac-9c9c-3575ade05397	645dce1e-7159-4b1b-86f0-0bc601f77b4a	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
05a18997-b12b-4e15-a264-a02d11e168a5	2bebe474-6406-409e-904c-ff7865ac755e	c02fcc25-b9f3-4473-bf1a-80abbdc73474
9e3a3199-58dd-4931-97e3-781787140e5e	f3c04916-f30d-4360-b465-c5eb262dce94	9e00a085-1e03-4bb5-b18d-65d93f16f743
7e465532-f951-4748-b68a-4e67531cd98f	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
57d11a34-793d-4657-806b-d733f38b91cc	f927fc08-8f8a-4a0b-adec-d924091dcad1	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
e5b5d2a9-0e51-4d7a-92b2-46cd168ab3fd	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
e39ff3db-be97-4b2a-bbb0-a7ec0b30047e	0f6a77b3-b0c1-420a-943d-2ca4b161991d	220672be-7563-4b84-83f0-cbd497765462
e14aab69-a1ca-462b-8dc0-fae1ebb7a079	5d1b295d-a018-49a2-9c53-a639a3bf51ef	645dce1e-7159-4b1b-86f0-0bc601f77b4a
c2ac9da3-e22f-4575-aa21-837f1aca0e2e	2bdf8bc5-7def-47aa-94ca-7f298307ab35	a9b20768-6469-4d39-b0aa-c4ed19ae9897
ac4ec458-2544-483b-953a-1b214cb51c9f	2bdba617-734f-48a5-844c-c7ca5a68781b	f2d14b9e-18a1-4479-a5da-835c7443586f
430291c8-f719-498a-b383-a55e411273f1	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
af7b8ca8-fcca-427a-a85a-a6842058abf0	745820cf-14e3-4837-be8a-2f7151ec9131	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
c2b8f916-4568-4c01-8a57-bc14c7b5bc7f	9e00a085-1e03-4bb5-b18d-65d93f16f743	a9b20768-6469-4d39-b0aa-c4ed19ae9897
c585afe8-b614-498a-b74b-56b5428f0261	d1dbec9d-ce36-42b3-a467-0b1512f41545	5d1b295d-a018-49a2-9c53-a639a3bf51ef
0b9c600b-333c-4d92-be5d-5132d393b9ba	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1
f12ab2c2-a386-4711-8f9e-480a4a89f5fd	d9500d74-9405-4bb6-89b9-6b19147f2cc8	64d12d2a-f5a9-4109-b79f-561e15f878b6
522b4a9d-e9ae-4e54-86b0-339eaaacf6f2	f3c04916-f30d-4360-b465-c5eb262dce94	f2d14b9e-18a1-4479-a5da-835c7443586f
69945b9c-e1d2-4cd1-aed0-ba44c6518a92	a9b20768-6469-4d39-b0aa-c4ed19ae9897	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
330dc651-a325-4bc6-a0f9-145733a98c18	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
a56af526-5ac9-4b45-bcbf-f91db28b9ba7	c02fcc25-b9f3-4473-bf1a-80abbdc73474	d9500d74-9405-4bb6-89b9-6b19147f2cc8
b8d493e3-a3c6-41b4-ac4c-86ca90e09b40	a96df0df-f4a1-4d82-a655-2f7f94ace896	f927fc08-8f8a-4a0b-adec-d924091dcad1
a10981a5-034f-4447-96e5-9e4dc1099a33	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	04b123c0-c2ed-464f-b848-5637bbd7d89d
7512ea98-352c-4419-92bb-e4c6351bc15c	5d1b295d-a018-49a2-9c53-a639a3bf51ef	2bdba617-734f-48a5-844c-c7ca5a68781b
f3049604-154e-4847-939f-ec72cc0a7487	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	a96df0df-f4a1-4d82-a655-2f7f94ace896
00251556-caf0-4334-bcee-aa221abcd925	2bdba617-734f-48a5-844c-c7ca5a68781b	f3c04916-f30d-4360-b465-c5eb262dce94
0e55ae4e-90cf-4a0b-9999-f1abd7697ffa	f927fc08-8f8a-4a0b-adec-d924091dcad1	b0ed894a-610d-498c-b11f-ed47d2a87b29
a506a5d1-35c8-4ece-be31-0666553baf2b	f2d14b9e-18a1-4479-a5da-835c7443586f	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
7fab168e-8105-49ce-a21a-43a8ca2f7c26	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	31c3d5b3-8c7c-4cef-a037-2eccb1839791
040d2b36-bc7c-4dc0-aa0d-b7cab6ccc91c	cd3675d5-61d6-4adf-96d8-bb5867342208	2bdba617-734f-48a5-844c-c7ca5a68781b
d62be8ed-be5a-451e-a227-ebb2de3b3573	960823cf-d908-4246-8fa0-0ac6118797ca	2bdba617-734f-48a5-844c-c7ca5a68781b
5802f49e-ac5c-44b9-a8e7-2c4668ab556d	f3c04916-f30d-4360-b465-c5eb262dce94	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
19459512-964f-4698-ba56-a0afd06b3d38	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	64d12d2a-f5a9-4109-b79f-561e15f878b6
3879a44e-1d22-4d9c-b49b-a78940c4958d	2bdba617-734f-48a5-844c-c7ca5a68781b	04b123c0-c2ed-464f-b848-5637bbd7d89d
a96e8277-9563-47dd-b37d-e3b79b36beb5	9e00a085-1e03-4bb5-b18d-65d93f16f743	2bdba617-734f-48a5-844c-c7ca5a68781b
edb39c81-ead7-4b33-b8be-62c97d932b3f	7575e78a-a78b-4900-9fb3-b30c925e5f89	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
476d665c-89b2-4115-b2b9-e296034e9a2a	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	9e00a085-1e03-4bb5-b18d-65d93f16f743
8f573265-3365-4eb4-8def-736a75a48617	960823cf-d908-4246-8fa0-0ac6118797ca	645dce1e-7159-4b1b-86f0-0bc601f77b4a
4ca48b60-7905-46a1-bbca-f7a3366fc13a	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	c02fcc25-b9f3-4473-bf1a-80abbdc73474
d34ce99c-c755-4cf4-a309-536a723b26d9	2bdba617-734f-48a5-844c-c7ca5a68781b	220672be-7563-4b84-83f0-cbd497765462
f22e73f7-3f77-40e9-ba62-01373184cc19	6a766343-b2eb-491f-8abb-ac90dd69fa95	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
5576e019-f757-4d36-aeda-bd81d5903ec5	64d12d2a-f5a9-4109-b79f-561e15f878b6	7d2d10ef-c751-4b4c-aff4-8f47c9952491
4e3ab6cb-856c-44c5-85a3-459608b9464c	b0afe2ef-0b3d-481d-9654-f9e67207757d	31c3d5b3-8c7c-4cef-a037-2eccb1839791
cb8d6e90-b615-4d15-aa64-8d7b1a31148f	5d1b295d-a018-49a2-9c53-a639a3bf51ef	4ac4c910-d783-48d5-ae41-b542e8cb666f
b39453ea-af2f-460e-bc75-b151fb9245f6	745820cf-14e3-4837-be8a-2f7151ec9131	2bdba617-734f-48a5-844c-c7ca5a68781b
92625cda-f292-4302-b3d5-9d39cce7ce6e	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	a96df0df-f4a1-4d82-a655-2f7f94ace896
86e6ae9e-29b3-4333-b877-ca1477c5c312	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	d9500d74-9405-4bb6-89b9-6b19147f2cc8
25cd82a1-0078-471e-8076-41e1749d8ee7	645dce1e-7159-4b1b-86f0-0bc601f77b4a	220672be-7563-4b84-83f0-cbd497765462
1b628cb5-bbaf-4ec7-8db2-32701df6e7b1	16eca672-7fea-4e30-a715-4aaac96518ce	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
9fb7575d-a7f0-48fe-ad91-2ec368d4d1b9	645dce1e-7159-4b1b-86f0-0bc601f77b4a	2bebe474-6406-409e-904c-ff7865ac755e
92221585-c683-4056-bcaf-3b381ad863f6	d1dbec9d-ce36-42b3-a467-0b1512f41545	220672be-7563-4b84-83f0-cbd497765462
1bde168f-8556-458d-b6cc-adbd27dacb33	d9500d74-9405-4bb6-89b9-6b19147f2cc8	f927fc08-8f8a-4a0b-adec-d924091dcad1
f77b295b-d9e6-4dcd-846b-b34f23aaad0c	d1dbec9d-ce36-42b3-a467-0b1512f41545	7575e78a-a78b-4900-9fb3-b30c925e5f89
a1ab1a95-f695-4a70-afa1-59dfc1619e7e	d9500d74-9405-4bb6-89b9-6b19147f2cc8	a9b20768-6469-4d39-b0aa-c4ed19ae9897
e0dfa697-963f-475d-9152-50de9de5886a	2bdf8bc5-7def-47aa-94ca-7f298307ab35	f3c04916-f30d-4360-b465-c5eb262dce94
965cb268-a2ac-4df4-a983-16a67c81476b	d1ec15b3-32ad-42af-b82b-32e4ccccca84	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
d621d23e-3fa0-41db-ae32-70a45461829f	2bdf8bc5-7def-47aa-94ca-7f298307ab35	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
00c67395-d2d1-4e92-bd42-92baa0485763	d9500d74-9405-4bb6-89b9-6b19147f2cc8	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
599287fc-308d-4286-bdfb-09f023a047fa	7d2d10ef-c751-4b4c-aff4-8f47c9952491	c6ef708c-22a7-4dea-85a9-bfc2f5e63608
d10ac551-3bf2-451e-b32e-7d9b28f86d81	64d12d2a-f5a9-4109-b79f-561e15f878b6	b0afe2ef-0b3d-481d-9654-f9e67207757d
2a4508b1-d6c1-4217-a5f6-eb965e12016a	04b123c0-c2ed-464f-b848-5637bbd7d89d	4ac4c910-d783-48d5-ae41-b542e8cb666f
d080eb5e-5d50-4aa3-938c-b6199ffc1c76	f3c04916-f30d-4360-b465-c5eb262dce94	f927fc08-8f8a-4a0b-adec-d924091dcad1
b864d7bd-e9c5-4bd6-b921-1c777eca80b6	745820cf-14e3-4837-be8a-2f7151ec9131	c02fcc25-b9f3-4473-bf1a-80abbdc73474
0af3dc1a-628e-45cb-a2f5-6d66ca50bb7b	645dce1e-7159-4b1b-86f0-0bc601f77b4a	7472ab8a-901e-4dac-a330-9bbe4eda5a5a
476bd4a2-8ad0-43a4-a95f-e549fe2964bf	31c3d5b3-8c7c-4cef-a037-2eccb1839791	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785
48855688-5dba-4c40-9dfc-3459bf62e73d	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	c02fcc25-b9f3-4473-bf1a-80abbdc73474
8e848450-3561-4958-b352-2d5e9a5dfa84	645dce1e-7159-4b1b-86f0-0bc601f77b4a	d1dbec9d-ce36-42b3-a467-0b1512f41545
1e3918c3-3d1f-4b2c-acc7-2c85a764c432	4ac4c910-d783-48d5-ae41-b542e8cb666f	f927fc08-8f8a-4a0b-adec-d924091dcad1
f9b48d2a-321d-4096-90c2-003059b16016	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	64d12d2a-f5a9-4109-b79f-561e15f878b6
5ea86c9a-e4eb-4b98-9ca6-ca2e52315c0b	960823cf-d908-4246-8fa0-0ac6118797ca	64d12d2a-f5a9-4109-b79f-561e15f878b6
24c9d253-a2aa-4460-8d3e-01a844f1f229	4ac4c910-d783-48d5-ae41-b542e8cb666f	a82ca232-27f5-4edd-a1d8-4678f55e8c8b
327ba859-5d98-454d-a1df-cee9737bb68d	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	693dab47-5108-490b-9a10-97ff75796112
6f8e896c-a69e-4199-960a-7d82b22e197c	d9500d74-9405-4bb6-89b9-6b19147f2cc8	f2d14b9e-18a1-4479-a5da-835c7443586f
78972431-7355-4370-bb9d-5098b5d48cfa	2bdf8bc5-7def-47aa-94ca-7f298307ab35	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c
3f6fe8fa-619d-4f2f-8b1e-ba830fce3ffb	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	a9b20768-6469-4d39-b0aa-c4ed19ae9897
ad1c85ab-7b02-44df-99a4-eebca53015b9	4ac4c910-d783-48d5-ae41-b542e8cb666f	2bebe474-6406-409e-904c-ff7865ac755e
54d76ea4-1866-43f0-a365-f5503e26cffa	d1dbec9d-ce36-42b3-a467-0b1512f41545	d9500d74-9405-4bb6-89b9-6b19147f2cc8
5fb1ba2a-a669-4f94-b956-08a4e926239c	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	220672be-7563-4b84-83f0-cbd497765462
01ad7351-5565-4c48-b4b8-db3c6a1f5f08	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	2bdba617-734f-48a5-844c-c7ca5a68781b
b9b73d8b-dff9-42ad-b603-2dae6ac4931e	cd3675d5-61d6-4adf-96d8-bb5867342208	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
340abc84-70e8-4c1a-ae4c-4fa7f4b942f8	645dce1e-7159-4b1b-86f0-0bc601f77b4a	d9500d74-9405-4bb6-89b9-6b19147f2cc8
d46c7828-cc1f-4fd3-bdcd-3933fe4ecc13	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
25e12390-56e8-4cba-9533-42599b385ea1	f927fc08-8f8a-4a0b-adec-d924091dcad1	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
edf1822a-462c-42c2-8645-281394a2355e	f2d14b9e-18a1-4479-a5da-835c7443586f	57d296e1-7af7-4cfc-afd2-7bc6352a65e6
d7c666f9-f1e7-46f5-b95f-e2afe6387bc1	f927fc08-8f8a-4a0b-adec-d924091dcad1	b0afe2ef-0b3d-481d-9654-f9e67207757d
67ec847d-23a8-4e88-befb-495931d4e5ae	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	0f6a77b3-b0c1-420a-943d-2ca4b161991d
cedb9de0-b359-47e6-8dfb-865c29b4b828	6a766343-b2eb-491f-8abb-ac90dd69fa95	16eca672-7fea-4e30-a715-4aaac96518ce
febac0b0-60aa-4f59-b2ce-a7b4638a3e6b	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	9e00a085-1e03-4bb5-b18d-65d93f16f743
cfda9d44-f69f-40a7-87a8-6b71042e7bc2	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	2bdba617-734f-48a5-844c-c7ca5a68781b
1a56a906-e8a3-498f-9e0e-6b0b6bc38609	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	cd3675d5-61d6-4adf-96d8-bb5867342208
e1b9ff6c-c626-4ba4-bf0f-b757044c12b7	745820cf-14e3-4837-be8a-2f7151ec9131	6a766343-b2eb-491f-8abb-ac90dd69fa95
e705dd9a-3571-4ad1-a32d-36f7d26867a4	b0ed894a-610d-498c-b11f-ed47d2a87b29	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
d4c717e1-94b9-4d89-ad85-dedca7be60a5	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	d1ec15b3-32ad-42af-b82b-32e4ccccca84
52a74044-1c36-4dfc-a13d-cec38b96bcdd	693dab47-5108-490b-9a10-97ff75796112	5d1b295d-a018-49a2-9c53-a639a3bf51ef
6af6db48-60aa-437a-9583-6d9b792fab10	5d1b295d-a018-49a2-9c53-a639a3bf51ef	d9500d74-9405-4bb6-89b9-6b19147f2cc8
fcb8fc4b-e469-4f82-bf28-c5a3ddcbb356	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	b0ed894a-610d-498c-b11f-ed47d2a87b29
4263340c-c3e3-4451-b432-356bedde8497	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	f8c6500d-bbf6-4c88-959c-c67c7e572fc0
58398837-2613-48e3-94d3-658ae4d067fb	220672be-7563-4b84-83f0-cbd497765462	2bdf8bc5-7def-47aa-94ca-7f298307ab35
8031c68a-62f5-4464-924c-29e9affb0a2e	2bebe474-6406-409e-904c-ff7865ac755e	6f67e1b3-4b5b-4359-b7ea-583eebbfde21
2ceaa87c-aea1-44ec-9d6a-e7c4ea23b1c5	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	76da11f5-10d2-4e79-af6d-1b92c4f2a0c0
bd61043f-741b-4be0-91a5-8b5acc14d478	f2d14b9e-18a1-4479-a5da-835c7443586f	f3c04916-f30d-4360-b465-c5eb262dce94
\.


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public."group" ("groupId", name, description, "createdAt", "updatedAt", "ownerUserId", "imageUrl", visibility) FROM stdin;
76de736c-3969-4979-8f1a-6a4afe6d8d7e	JS for images	a group dedicated for image transformations enthousiaste developpers to share their programmes in different programming languages as javscript / python / c++ and other languages join now 	2024-06-22 16:56:47.734838	2024-06-22 16:56:47.734838	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	localhost:3000/uploads/avatars/8f88a9c4-d1fe-45d6-90e6-14e41e33b45e.jpg	private
b239d202-2b9d-44b5-9f94-a596fbcdf608	JS advanced group	all types of files transformation programmes in nodeJS	2024-06-22 17:08:26.900232	2024-06-22 17:08:26.900232	a9b20768-6469-4d39-b0aa-c4ed19ae9897	localhost:3000/uploads/avatars/d0fcac62-f48c-4322-aeb2-263e320f3380.png	private
9704c250-2c29-4f49-a5dc-c3fface6a852	frontendDev		2024-06-22 17:11:30.321864	2024-06-22 17:11:30.321864	b0ed894a-610d-498c-b11f-ed47d2a87b29	\N	public
f5bf0ba1-59b3-4ebf-8bf0-659482d81487	Node for backend	group for nodeJs developpers	2024-06-22 17:19:12.106356	2024-06-22 17:19:12.106356	b0ed894a-610d-498c-b11f-ed47d2a87b29	localhost:3000/uploads/avatars/ab7b4122-a537-4abe-8a64-003b6cf8c8aa.png	public
21de695d-1881-42e4-a55a-488e7b9803cb	i hate php		2024-06-22 17:33:05.099321	2024-06-22 17:33:05.099321	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	localhost:3000/uploads/avatars/0fdaa2e9-a20b-45c3-9f63-4039927bdbe7.png	public
3d534968-0a02-4591-a212-9bcea2647345	Design patterns in C++		2024-06-22 17:35:34.164274	2024-06-22 17:35:34.164274	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	localhost:3000/uploads/avatars/1e2b3248-3b3d-47e3-9ca7-b84488a97d24.jpg	private
a1ca570a-9fa9-499a-8976-d5a1623d5cd8	Cloud AWS		2024-06-22 17:40:41.521895	2024-06-22 17:40:41.521895	f927fc08-8f8a-4a0b-adec-d924091dcad1	localhost:3000/uploads/avatars/ff4355dd-6056-4bc8-9dc0-633951b23d71.png	private
72ccf4fa-a557-4a29-ad3b-a2bc1c822253	C++ (GOAT)	Only goats here 	2024-06-22 17:00:52.904667	2024-06-22 17:00:52.904667	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	localhost:3000/uploads/avatars/4f16780f-63ba-4b5a-b5c7-102a91499392.png	public
\.


--
-- Data for Name: group_programs; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.group_programs ("groupId", "programId") FROM stdin;
72ccf4fa-a557-4a29-ad3b-a2bc1c822253	b94a2717-25d8-4468-86ef-ff848914d361
72ccf4fa-a557-4a29-ad3b-a2bc1c822253	f78c6ff8-c684-42cf-96e5-729f6eea2c2a
72ccf4fa-a557-4a29-ad3b-a2bc1c822253	20ff146f-bd26-4272-8dce-016480cf0455
b239d202-2b9d-44b5-9f94-a596fbcdf608	e164f922-a776-40cd-9202-0ac5ebacab76
b239d202-2b9d-44b5-9f94-a596fbcdf608	cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc
b239d202-2b9d-44b5-9f94-a596fbcdf608	eb202c43-be73-455e-a9e8-de2724e9a8cd
9704c250-2c29-4f49-a5dc-c3fface6a852	ceb9f2e5-5642-4e62-b043-aac33b13ddb9
9704c250-2c29-4f49-a5dc-c3fface6a852	d5e3fdde-0228-487b-a591-f00f3ba3722b
9704c250-2c29-4f49-a5dc-c3fface6a852	1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e
\.


--
-- Data for Name: program; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.program ("programId", description, "programmingLanguage", "sourceCode", visibility, "inputTypes", "outputTypes", "createdAt", "updatedAt", "userUserId", "isProgramGroup") FROM stdin;
327c8fef-d34c-45e8-aec2-0d226e8347ad	generating reports from json and yaml files 	javascript	const fs = require('fs-extra');\nconst yaml = require('yaml');\nconst path = require('path');\n\nasync function processFilesAndGenerateReports(inputJsonPaths, inputYamlPaths, outputJsonPath, outputYamlPath) {\n  const summary = { jsonFiles: [], yamlFiles: [] };\n\n  for (const filePath of inputJsonPaths) {\n    const data = await fs.readJson(filePath);\n    summary.jsonFiles.push({ file: path.basename(filePath), data });\n  }\n\n  for (const filePath of inputYamlPaths) {\n    const data = yaml.parse(await fs.readFile(filePath, 'utf8'));\n    summary.yamlFiles.push({ file: path.basename(filePath), data });\n  }\n\n  await fs.writeJson(outputJsonPath, summary, { spaces: 2 });\n  await fs.writeFile(outputYamlPath, yaml.stringify(summary));\n  console.log('Reports have been generated in JSON and YAML formats.');\n}\n\nconst inputJsonPaths = [INPUT_FILE_PATH_0, INPUT_FILE_PATH_1]; \nconst inputYamlPaths = [INPUT_FILE_PATH_2, INPUT_FILE_PATH_3]; \nconst outputJsonPath = OUTPUT_FILE_PATH_0;\nconst outputYamlPath = OUTPUT_FILE_PATH_1; \n\nprocessFilesAndGenerateReports(inputJsonPaths, inputYamlPaths, outputJsonPath, outputYamlPath);\n	public	json	yml	2024-06-21 21:51:47.029329	2024-06-21 21:51:47.029329	6a766343-b2eb-491f-8abb-ac90dd69fa95	f
20ff146f-bd26-4272-8dce-016480cf0455	a c++ program that reads txt file of this format (John Doe, johndoe@example.com, 30) and gnerate a json file with data	c++	#include <iostream>\n#include <fstream>\n#include <sstream>\n#include <vector>\n#include <string>\n\n// Structure to hold user data\nstruct User\n{\n    std::string name;\n    std::string email;\n    int age;\n};\n\n// Function to read users from a text file\nstd::vector<User> readUsersFromFile(const std::string &filename)\n{\n    std::vector<User> users;\n    std::ifstream infile(filename);\n    std::string line;\n\n    while (std::getline(infile, line))\n    {\n        std::istringstream iss(line);\n        std::string name, email, ageStr;\n        if (std::getline(iss, name, ',') &&\n            std::getline(iss, email, ',') &&\n            std::getline(iss, ageStr))\n        {\n            User user;\n            user.name = name;\n            user.email = email;\n            user.age = std::stoi(ageStr);\n            users.push_back(user);\n        }\n    }\n\n    return users;\n}\n\n// Function to write users to a JSON file\nvoid writeUsersToJson(const std::string &filename, const std::vector<User> &users)\n{\n    std::ofstream outfile(filename);\n    outfile << "[\\n";\n    for (size_t i = 0; i < users.size(); ++i)\n    {\n        outfile << "  {\\n";\n        outfile << "    \\"name\\": \\"" << users[i].name << "\\",\\n";\n        outfile << "    \\"email\\": \\"" << users[i].email << "\\",\\n";\n        outfile << "    \\"age\\": " << users[i].age << "\\n";\n        outfile << "  }";\n        if (i < users.size() - 1)\n        {\n            outfile << ",";\n        }\n        outfile << "\\n";\n    }\n    outfile << "]";\n}\n\nint main()\n{\n    std::string inputFilename = INPUT_FILE_PATH_0;\n    std::string outputFilename = OUTPUT_FILE_PATH_0;\n\n    // Read users from the text file\n    std::vector<User> users = readUsersFromFile(inputFilename);\n\n    // Write users to the JSON file\n    writeUsersToJson(outputFilename, users);\n\n    std::cout << "User data has been written to " << outputFilename << std::endl;\n\n    return 0;\n}\n	private	txt	json	2024-06-22 18:56:43.37739	2024-06-22 18:56:43.37739	f927fc08-8f8a-4a0b-adec-d924091dcad1	t
e0ecda2a-7159-4e41-bff6-53a6e34060a8	this is an example of a python code that reads the contents of json/yml/ and png image and writtes it in a pdf file	python	import yaml\nimport json\nfrom pathlib import Path\nfrom reportlab.lib.pagesizes import letter\nfrom reportlab.pdfgen import canvas\nfrom PIL import Image\n\n# File paths\nyaml_file = INPUT_FILE_PATH_0\njson_file = INPUT_FILE_PATH_1\npng_file = Path(INPUT_FILE_PATH_2)\npdf_file = Path(OUTPUT_FILE_PATH_0)\n\n# Read YAML file\nwith open(yaml_file, 'r') as file:\n    user_details = yaml.safe_load(file)\n\n# Read JSON file\nwith open(json_file, 'r') as file:\n    articles = json.load(file)\n\n# Create PDF\nc = canvas.Canvas(str(pdf_file), pagesize=letter)\nwidth, height = letter\n\n# User details\nc.setFont("Helvetica", 12)\ny = height - 40\nfor key, value in user_details.items():\n    c.drawString(40, y, f"{key}: {value}")\n    y -= 20\n\n# Articles\nc.drawString(40, y - 20, "Articles:")\ny -= 40\nfor article in articles:\n    c.drawString(60, y, f"Title: {article['title']}")\n    y -= 20\n    c.drawString(80, y, f"Content: {article['content']}")\n    y -= 40\n\n# Add PNG image\nimage = Image.open(png_file)\nimage_width, image_height = image.size\nimage_ratio = image_height / image_width\nc.drawImage(png_file, 40, 40, width - 80, (width - 80) * image_ratio)\n\nc.save()\n\nprint("PDF created successfully.")\n	public	json,yml,png	pdf	2024-06-21 18:45:29.694812	2024-06-21 18:45:29.694812	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	f
b85d1b4b-f01d-41f8-b273-ac2816c566b5	c++ code that takes a file of numbers and test the performance of differnt sort algorithmes (no output)	c++	#include <iostream>\n#include <vector>\n#include <fstream>\n#include <chrono>\n#include <algorithm>\n\n// Function to read numbers from a file\nstd::vector<int> readNumbersFromFile(const std::string& filename) {\n    std::vector<int> numbers;\n    std::ifstream inputFile(filename);\n    if (!inputFile) {\n        std::cerr << "Error opening file: " << filename << std::endl;\n        return numbers;\n    }\n\n    int number;\n    while (inputFile >> number) {\n        numbers.push_back(number);\n    }\n\n    inputFile.close();\n    return numbers;\n}\n\n// Bubble Sort\nvoid bubbleSort(std::vector<int>& arr) {\n    int n = arr.size();\n    for (int i = 0; i < n - 1; ++i) {\n        for (int j = 0; j < n - 1 - i; ++j) {\n            if (arr[j] > arr[j + 1]) {\n                std::swap(arr[j], arr[j + 1]);\n            }\n        }\n    }\n}\n\n// Insertion Sort\nvoid insertionSort(std::vector<int>& arr) {\n    int n = arr.size();\n    for (int i = 1; i < n; ++i) {\n        int key = arr[i];\n        int j = i - 1;\n        while (j >= 0 && arr[j] > key) {\n            arr[j + 1] = arr[j];\n            --j;\n        }\n        arr[j + 1] = key;\n    }\n}\n\n// Partition function for Quick Sort\nint partition(std::vector<int>& arr, int low, int high) {\n    int pivot = arr[high];\n    int i = low - 1;\n    for (int j = low; j < high; ++j) {\n        if (arr[j] < pivot) {\n            ++i;\n            std::swap(arr[i], arr[j]);\n        }\n    }\n    std::swap(arr[i + 1], arr[high]);\n    return i + 1;\n}\n\n// Quick Sort\nvoid quickSort(std::vector<int>& arr, int low, int high) {\n    if (low < high) {\n        int pi = partition(arr, low, high);\n        quickSort(arr, low, pi - 1);\n        quickSort(arr, pi + 1, high);\n    }\n}\n\n// Function to measure the time taken by a sorting function\ntemplate <typename Func>\nvoid measureSortTime(Func sortFunction, std::vector<int> arr, const std::string& sortName) {\n    auto start = std::chrono::high_resolution_clock::now();\n    sortFunction(arr);\n    auto end = std::chrono::high_resolution_clock::now();\n    std::chrono::duration<double> elapsed = end - start;\n    std::cout << sortName << " took " << elapsed.count() << " seconds." << std::endl;\n}\n\nint main() {\n    std::string filename = INPUT_FILE_PATH_0; // Replace with your filename\n    std::vector<int> numbers = readNumbersFromFile(filename);\n    if (numbers.empty()) {\n        return 1;\n    }\n\n    std::vector<int> numbersBubble = numbers;\n    std::vector<int> numbersInsertion = numbers;\n    std::vector<int> numbersQuick = numbers;\n\n    measureSortTime(bubbleSort, numbersBubble, "Bubble Sort");\n    measureSortTime(insertionSort, numbersInsertion, "Insertion Sort");\n    measureSortTime([&](std::vector<int>& arr) { quickSort(arr, 0, arr.size() - 1); }, numbersQuick, "Quick Sort");\n\n    return 0;\n}\n	public	txt		2024-06-21 19:42:30.977933	2024-06-21 19:42:30.977933	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	f
dd7734cc-3f4f-48ac-bcea-f38a122ab792	python code that transfrom sql queries to csv data and log erros in a pdf file if found \nqueries must be users inserts (name, email, password)	python	import re\nimport pandas as pd\nfrom reportlab.lib.pagesizes import letter\nfrom reportlab.pdfgen import canvas\nfrom pathlib import Path\n\ndef read_sql_queries(filename):\n    with open(filename, 'r') as file:\n        queries = file.readlines()\n    return queries\n\ndef parse_sql_query(query):\n    match = re.match(r"INSERT INTO users \\(name, email, password\\) VALUES \\('([^']+)', '([^']+)', '([^']+)'\\);", query)\n    if match:\n        return {'name': match.group(1), 'email': match.group(2), 'password': match.group(3)}\n    else:\n        return None\n\ndef write_to_csv(data, filename):\n    df = pd.DataFrame(data)\n    df.to_csv(filename, index=False)\n\ndef log_errors_to_pdf(errors, filename):\n    c = canvas.Canvas(filename, pagesize=letter)\n    width, height = letter\n    c.setFont("Helvetica", 12)\n\n    y = height - 40  # start from top of the page\n    for error in errors:\n        c.drawString(30, y, error)\n        y -= 20  # move to the next line\n        if y < 40:  # if we reach the bottom of the page\n            c.showPage()  # create a new page\n            c.setFont("Helvetica", 12)\n            y = height - 40  # reset y position\n\n    c.save()\n\ndef main():\n    input_filename = INPUT_FILE_PATH_0\n    output_csv_filename = OUTPUT_FILE_PATH_0\n    error_pdf_filename = OUTPUT_FILE_PATH_1\n\n    queries = read_sql_queries(input_filename)\n    valid_data = []\n    errors = []\n\n    for query in queries:\n        parsed_data = parse_sql_query(query.strip())\n        if parsed_data:\n            valid_data.append(parsed_data)\n        else:\n            errors.append(f"Error in query: {query.strip()}")\n\n    if valid_data:\n        write_to_csv(valid_data, output_csv_filename)\n    \n    if errors:\n        log_errors_to_pdf(errors, error_pdf_filename)\n\nif __name__ == "__main__":\n    main()\n	public	txt	csv,pdf	2024-06-21 19:52:30.65671	2024-06-21 19:52:30.65671	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	f
0f81f051-ed2a-4931-87bf-544c4f6fe647	python code that takes in a png image draw an red (X) on it and returns a jpeg file from the same image 	python	from PIL import Image, ImageDraw\nimport pathlib\n\ndef draw_big_x_on_image(input_image_path, output_image_path):\n    # Open an existing image\n    with Image.open(input_image_path) as img:\n        # Create a draw object\n        draw = ImageDraw.Draw(img)\n        width, height = img.size\n\n        # Define the coordinates for the big X\n        x1, y1 = 0, 0\n        x2, y2 = width, height\n        x3, y3 = 0, height\n        x4, y4 = width, 0\n\n        # Draw two diagonal lines to form the X\n        line_width = 10  # You can adjust the width of the lines\n        draw.line((x1, y1, x2, y2), fill="red", width=line_width)\n        draw.line((x3, y3, x4, y4), fill="red", width=line_width)\n\n        # Save the image as a JPEG file\n        img = img.convert('RGB')  # Convert image to RGB mode if not already\n        img.save(output_image_path, 'JPEG')\n\ndef main():\n    input_image_path = INPUT_FILE_PATH_0 # Replace with your input PNG file path\n    output_image_path = OUTPUT_FILE_PATH_0  # Replace with your desired output JPEG file path\n    draw_big_x_on_image(input_image_path, output_image_path)\n\nif __name__ == "__main__":\n    main()\n	public	png	jpeg	2024-06-21 19:59:40.995018	2024-06-21 19:59:40.995018	645dce1e-7159-4b1b-86f0-0bc601f77b4a	f
4997a34d-85e4-4763-83e5-2dc39be7fdd9	python code that sends a get http request to (https://random-data-api.com/api/v2/users)\nand save the data in a json file	python	import requests\nimport json\nfrom pathlib import Path\n\ndef fetch_data_from_api(api_url, output_json_path):\n    response = requests.get(api_url)\n    if response.status_code == 200:\n        data = response.json()\n        with open(output_json_path, 'w') as json_file:\n            json.dump(data, json_file, indent=4)\n    else:\n        print(f"Failed to fetch data: {response.status_code}")\n\ndef main():\n    api_url = 'https://random-data-api.com/api/v2/users' # Replace with your API URL\n    output_json_path = OUTPUT_FILE_PATH_0  # Replace with your output JSON file path\n    fetch_data_from_api(api_url, output_json_path)\n\nif __name__ == "__main__":\n    main()\n	public		json	2024-06-21 20:31:17.100635	2024-06-21 20:31:17.100635	645dce1e-7159-4b1b-86f0-0bc601f77b4a	f
2556c842-c8b7-4e31-8e7b-dae4fd49b6f8	JS code to add watermark to png images 	javascript	const Jimp = require('jimp');\n\nasync function addWatermark(inputImagePath, watermarkText, outputImagePath) {\n  try {\n    const image = await Jimp.read(inputImagePath);\n    const font = await Jimp.loadFont(Jimp.FONT_SANS_32_WHITE);\n    const width = image.bitmap.width;\n    const height = image.bitmap.height;\n\n    image.print(font, width - 200, height - 50, watermarkText);\n    await image.writeAsync(outputImagePath);\n    console.log('Watermark has been added to the image.');\n  } catch (error) {\n    console.error(error);\n  }\n}\n\nconst inputImagePath = INPUT_FILE_PATH_0;\nconst watermarkText = 'Sample Watermark';\nconst outputImagePath = OUTPUT_FILE_PATH_0 ;\n\naddWatermark(inputImagePath, watermarkText, outputImagePath);\n	public	png	png	2024-06-21 21:33:14.411311	2024-06-21 21:33:14.411311	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	f
8fe11bba-6a07-4c9d-bafb-2d5682a8444e	c++ searching for elements algorithms 	c++	#include <iostream>\n#include <vector>\n#include <algorithm>\n\n// Linear Search\nint linearSearch(const std::vector<int>& arr, int target) {\n    for (int i = 0; i < arr.size(); ++i) {\n        if (arr[i] == target) {\n            return i;\n        }\n    }\n    return -1;\n}\n\n// Binary Search (Array must be sorted)\nint binarySearch(const std::vector<int>& arr, int target) {\n    int left = 0, right = arr.size() - 1;\n    while (left <= right) {\n        int mid = left + (right - left) / 2;\n        if (arr[mid] == target) {\n            return mid;\n        }\n        if (arr[mid] < target) {\n            left = mid + 1;\n        } else {\n            right = mid - 1;\n        }\n    }\n    return -1;\n}\n\nint main() {\n    std::vector<int> arr = {5, 7, 23, 32, 34, 62};\n    int target1 = 23;\n    int target2 = 62;\n\n    int index1 = linearSearch(arr, target1);\n    int index2 = binarySearch(arr, target2);\n\n    std::cout << "Linear Search: Index of " << target1 << " is " << index1 << std::endl;\n    std::cout << "Binary Search: Index of " << target2 << " is " << index2 << std::endl;\n\n    return 0;\n}\n	public			2024-06-21 21:54:19.333019	2024-06-21 21:54:19.333019	6a766343-b2eb-491f-8abb-ac90dd69fa95	f
72ac885d-73d6-4179-a7ca-71bb98cb5486	Mergin arrays in c++	c++	#include <iostream>\n#include <vector>\n#include <queue>\n\n// Merge Two Sorted Arrays\nstd::vector<int> mergeTwoSortedArrays(const std::vector<int>& arr1, const std::vector<int>& arr2) {\n    std::vector<int> result;\n    int i = 0, j = 0;\n\n    while (i < arr1.size() && j < arr2.size()) {\n        if (arr1[i] < arr2[j]) {\n            result.push_back(arr1[i++]);\n        } else {\n            result.push_back(arr2[j++]);\n        }\n    }\n\n    while (i < arr1.size()) {\n        result.push_back(arr1[i++]);\n    }\n\n    while (j < arr2.size()) {\n        result.push_back(arr2[j++]);\n    }\n\n    return result;\n}\n\n// Merge K Sorted Arrays\nstd::vector<int> mergeKSortedArrays(const std::vector<std::vector<int>>& arrays) {\n    auto compare = [](const std::pair<int, std::pair<int, int>>& a, const std::pair<int, std::pair<int, int>>& b) {\n        return a.first > b.first;\n    };\n    \n    std::priority_queue<std::pair<int, std::pair<int, int>>, std::vector<std::pair<int, std::pair<int, int>>>, decltype(compare)> minHeap(compare);\n    std::vector<int> result;\n\n    for (int i = 0; i < arrays.size(); ++i) {\n        if (!arrays[i].empty()) {\n            minHeap.push({arrays[i][0], {i, 0}});\n        }\n    }\n\n    while (!minHeap.empty()) {\n        auto [value, indices] = minHeap.top();\n        minHeap.pop();\n        result.push_back(value);\n        int arrayIndex = indices.first;\n        int elementIndex = indices.second;\n        if (elementIndex + 1 < arrays[arrayIndex].size()) {\n            minHeap.push({arrays[arrayIndex][elementIndex + 1], {arrayIndex, elementIndex + 1}});\n        }\n    }\n\n    return result;\n}\n\nint main() {\n    std::vector<int> arr1 = {1, 4, 7};\n    std::vector<int> arr2 = {2, 5, 8};\n    std::vector<int> arr3 = {3, 6, 9};\n\n    std::vector<std::vector<int>> arrays = {arr1, arr2, arr3};\n\n    std::vector<int> mergedTwo = mergeTwoSortedArrays(arr1, arr2);\n    std::vector<int> mergedK = mergeKSortedArrays(arrays);\n\n    std::cout << "Merged Two Arrays: ";\n    for (int num : mergedTwo) std::cout << num << " ";\n    std::cout << std::endl;\n\n    std::cout << "Merged K Arrays: ";\n    for (int num : mergedK) std::cout << num << " ";\n    std::cout << std::endl;\n\n    return 0;\n}\n	public			2024-06-21 21:55:13.485957	2024-06-21 21:55:13.485957	6a766343-b2eb-491f-8abb-ac90dd69fa95	f
b0d45f2b-2442-48cd-8911-591f4fcf0be7	Matrixs transformations algorithms in c++	c++	#include <iostream>\n#include <vector>\n\n// Transpose a Matrix\nstd::vector<std::vector<int>> transposeMatrix(const std::vector<std::vector<int>>& matrix) {\n    int rows = matrix.size();\n    int cols = matrix[0].size();\n    std::vector<std::vector<int>> transposed(cols, std::vector<int>(rows));\n\n    for (int i = 0; i < rows; ++i) {\n        for (int j = 0; j < cols; ++j) {\n            transposed[j][i] = matrix[i][j];\n        }\n    }\n\n    return transposed;\n}\n\n// Rotate a Matrix 90 Degrees Clockwise\nstd::vector<std::vector<int>> rotateMatrix(const std::vector<std::vector<int>>& matrix) {\n    int rows = matrix.size();\n    int cols = matrix[0].size();\n    std::vector<std::vector<int>> rotated(cols, std::vector<int>(rows));\n\n    for (int i = 0; i < rows; ++i) {\n        for (int j = 0; j < cols; ++j) {\n            rotated[j][rows - i - 1] = matrix[i][j];\n        }\n    }\n\n    return rotated;\n}\n\nint main() {\n    std::vector<std::vector<int>> matrix = {\n        {1, 2, 3},\n        {4, 5, 6},\n        {7, 8, 9}\n    };\n\n    std::vector<std::vector<int>> transposed = transposeMatrix(matrix);\n    std::vector<std::vector<int>> rotated = rotateMatrix(matrix);\n\n    std::cout << "Transposed Matrix:" << std::endl;\n    for (const auto& row : transposed) {\n        for (int num : row) std::cout << num << " ";\n        std::cout << std::endl;\n    }\n\n    std::cout << "Rotated Matrix:" << std::endl;\n    for (const auto& row : rotated) {\n        for (int num : row) std::cout << num << " ";\n        std::cout << std::endl;\n    }\n\n    return 0;\n}\n	public			2024-06-21 21:55:57.182028	2024-06-21 21:55:57.182028	6a766343-b2eb-491f-8abb-ac90dd69fa95	f
b94a2717-25d8-4468-86ef-ff848914d361	demonstration on how to use lists in c++	c++	#include <iostream>\n#include <list>\n\nint main()\n{\n    std::list<int> myList = {1, 2, 3, 4, 5};\n\n    // Adding elements\n    myList.push_back(6);\n    myList.push_front(0);\n\n    // Iterating and displaying elements\n    std::cout << "List elements: ";\n    for (const auto &element : myList)\n    {\n        std::cout << element << " ";\n    }\n    std::cout << std::endl;\n\n    // Accessing elements\n    std::cout << "First element: " << myList.front() << std::endl;\n    std::cout << "Last element: " << myList.back() << std::endl;\n\n    // Removing elements\n    myList.pop_back();\n    myList.pop_front();\n\n    // Displaying elements after removal\n    std::cout << "List elements after pop operations: ";\n    for (const auto &element : myList)\n    {\n        std::cout << element << " ";\n    }\n    std::cout << std::endl;\n\n    return 0;\n}\n	private			2024-06-22 18:46:50.437755	2024-06-22 18:46:50.437755	f927fc08-8f8a-4a0b-adec-d924091dcad1	t
f78c6ff8-c684-42cf-96e5-729f6eea2c2a	c++ lists demonstration	c++	#include <iostream>\n#include <list>\n\nint main()\n{\n    std::list<int> myList = {1, 2, 3, 4, 5};\n\n    // Adding elements\n    myList.push_back(6);\n    myList.push_front(0);\n\n    // Iterating and displaying elements\n    std::cout << "List elements: ";\n    for (const auto &element : myList)\n    {\n        std::cout << element << " ";\n    }\n    std::cout << std::endl;\n\n    // Accessing elements\n    std::cout << "First element: " << myList.front() << std::endl;\n    std::cout << "Last element: " << myList.back() << std::endl;\n\n    // Removing elements\n    myList.pop_back();\n    myList.pop_front();\n\n    // Displaying elements after removal\n    std::cout << "List elements after pop operations: ";\n    for (const auto &element : myList)\n    {\n        std::cout << element << " ";\n    }\n    std::cout << std::endl;\n\n    return 0;\n}\n	private			2024-06-22 18:47:31.300957	2024-06-22 18:47:31.300957	f927fc08-8f8a-4a0b-adec-d924091dcad1	t
e164f922-a776-40cd-9202-0ac5ebacab76	simple todo application example using js	javascript	const todoList = [];\n\nfunction addTask(task) {\n    todoList.push(task);\n    console.log(`Task "${task}" added.`);\n}\n\nfunction removeTask(task) {\n    const index = todoList.indexOf(task);\n    if (index > -1) {\n        todoList.splice(index, 1);\n        console.log(`Task "${task}" removed.`);\n    } else {\n        console.log(`Task "${task}" not found.`);\n    }\n}\n\naddTask('Learn JavaScript');\naddTask('Build a project');\nremoveTask('Learn JavaScript');\nconsole.log(todoList);\n	private			2024-06-26 18:02:01.339199	2024-06-26 18:02:01.339199	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	t
cac0ee2e-03a3-40ad-bb58-2c2a43f8e3dc	email validator using javascript	javascript	function validateEmail(email) {\n    const regex = /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/;\n    return regex.test(email);\n}\n\nconsole.log(validateEmail('test@example.com'));  // Output: true\nconsole.log(validateEmail('invalid-email'));     // Output: false\n	private			2024-06-26 18:02:54.060544	2024-06-26 18:02:54.060544	b0ed894a-610d-498c-b11f-ed47d2a87b29	t
eb202c43-be73-455e-a9e8-de2724e9a8cd	js fetch api example	javascript	async function fetchData(url) {\n    try {\n        let response = await fetch(url);\n        if (!response.ok) {\n            throw new Error(`HTTP error! Status: ${response.status}`);\n        }\n        let data = await response.json();\n        console.log(data);\n    } catch (error) {\n        console.error('Error fetching data:', error);\n    }\n}\n\nfetchData('https://api.example.com/data');\n	private			2024-06-26 18:03:20.34263	2024-06-26 18:03:20.34263	b0ed894a-610d-498c-b11f-ed47d2a87b29	t
ceb9f2e5-5642-4e62-b043-aac33b13ddb9	\N	python	def is_prime(num):\n    if num <= 1:\n        return False\n    for i in range(2, int(num ** 0.5) + 1):\n        if num % i == 0:\n            return False\n    return True\n\nprint(is_prime(11))  # Output: True\nprint(is_prime(4))   # Output: False\n	private			2024-06-26 18:04:11.967315	2024-06-26 18:04:11.967315	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	t
d5e3fdde-0228-487b-a591-f00f3ba3722b	sum of arrays example in c++	c++	#include <iostream>\n\nint main()\n{\n    int arr[] = {1, 2, 3, 4, 5};\n    int sum = 0;\n    for (int i = 0; i < 5; ++i)\n    {\n        sum += arr[i];\n    }\n    std::cout << "Sum of array elements: " << sum << std::endl;\n    return 0;\n}\n	private			2024-06-26 18:04:37.939036	2024-06-26 18:04:37.939036	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	t
1f531e09-7a1f-4fe4-8eae-4a5e8a1a9c5e	\N	c++	#include <iostream>\n\nint main()\n{\n    std::cout << "Hello, World!" << std::endl;\n    return 0;\n}\n	private			2024-06-26 18:04:56.761381	2024-06-26 18:04:56.761381	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	t
88e39a98-56a3-4d25-936a-21dae870d0b3	js code to create thumbnails 3 versions up unitl now	javascript	const Jimp = require('jimp');\nconst fs = require('fs-extra');\nconst path = require('path');\n\nasync function createThumbnails(inputImagePaths, outputImagePaths, thumbnailSize = 100) {\n  for (let i = 0; i < inputImagePaths.length; i++) {\n    const inputFilePath = inputImagePaths[i];\n    const outputFilePath = outputImagePaths[i];\n    const image = await Jimp.read(inputFilePath);\n    const thumbnail = image.resize(thumbnailSize, Jimp.AUTO);\n    await thumbnail.writeAsync(outputFilePath);\n  }\n\n  console.log('Thumbnails have been created for the images.');\n}\n\nconst inputImagePaths = [INPUT_FILE_PATH_0, INPUT_FILE_PATH_1]; // Replace with your input image file paths\nconst outputImagePaths = [OUTPUT_FILE_PATH_0, OUTPUT_FILE_PATH_0]; // Replace with your output thumbnail file paths\n\ncreateThumbnails(inputImagePaths, outputImagePaths);\n\n// updates here this is another test \n// test for other stuf too \n	public	png	png	2024-06-21 21:45:49.043283	2024-06-21 21:45:49.043283	6a766343-b2eb-491f-8abb-ac90dd69fa95	f
25ba8c0b-e206-475b-a899-ebf6ddb9f593	this is a c++ programme with multiple versions for differnet sort algorithms 	c++	#include <iostream>\n#include <vector>\n#include <algorithm>\n\n// Bubble Sort\nvoid bubbleSort(std::vector<int>& arr) {\n    int n = arr.size();\n    for (int i = 0; i < n - 1; ++i) {\n        for (int j = 0; j < n - 1 - i; ++j) {\n            if (arr[j] > arr[j + 1]) {\n                std::swap(arr[j], arr[j + 1]);\n            }\n        }\n    }\n}\n\n// Insertion Sort\nvoid insertionSort(std::vector<int>& arr) {\n    int n = arr.size();\n    for (int i = 1; i < n; ++i) {\n        int key = arr[i];\n        int j = i - 1;\n        while (j >= 0 && arr[j] > key) {\n            arr[j + 1] = arr[j];\n            --j;\n        }\n        arr[j + 1] = key;\n    }\n}\n\n// Quick Sort\nint partition(std::vector<int>& arr, int low, int high) {\n    int pivot = arr[high];\n    int i = low - 1;\n    for (int j = low; j < high; ++j) {\n        if (arr[j] < pivot) {\n            ++i;\n            std::swap(arr[i], arr[j]);\n        }\n    }\n    std::swap(arr[i + 1], arr[high]);\n    return i + 1;\n}\n\nvoid quickSort(std::vector<int>& arr, int low, int high) {\n    if (low < high) {\n        int pi = partition(arr, low, high);\n        quickSort(arr, low, pi - 1);\n        quickSort(arr, pi + 1, high);\n    }\n}\n\nint main() {\n    std::vector<int> arr1 = {34, 7, 23, 32, 5, 62};\n    std::vector<int> arr2 = arr1;\n    std::vector<int> arr3 = arr1;\n\n    bubbleSort(arr1);\n    insertionSort(arr2);\n    quickSort(arr3, 0, arr3.size() - 1);\n\n    std::cout << "Bubble Sorted: ";\n    for (int num : arr1) std::cout << num << " ";\n    std::cout << std::endl;\n\n    std::cout << "Insertion Sorted: ";\n    for (int num : arr2) std::cout << num << " ";\n    std::cout << std::endl;\n\n    std::cout << "Quick Sorted: ";\n    for (int num : arr3) std::cout << num << " ";\n    std::cout << std::endl;\n\n    return 0;\n}\n	public			2024-06-21 21:52:58.045625	2024-06-21 21:52:58.045625	6a766343-b2eb-491f-8abb-ac90dd69fa95	f
\.


--
-- Data for Name: program-version; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public."program-version" ("programVersionId", version, "programmingLanguage", "sourceCode", "createdAt", "programProgramId") FROM stdin;
26941cb0-397e-46e4-a726-c5bb35005660	1.1.2	javascript	const Jimp = require('jimp');\nconst fs = require('fs-extra');\nconst path = require('path');\n\nconsole.log('1.1.2')\n\nasync function createThumbnails(inputImagePaths, outputImagePaths, thumbnailSize = 100) {\n  for (let i = 0; i < inputImagePaths.length; i++) {\n    const inputFilePath = inputImagePaths[i];\n    const outputFilePath = outputImagePaths[i];\n    const image = await Jimp.read(inputFilePath);\n    const thumbnail = image.resize(thumbnailSize, Jimp.AUTO);\n    await thumbnail.writeAsync(outputFilePath);\n  }\n\n  console.log('Thumbnails have been created for the images.');\n}\n\nconst inputImagePaths = [INPUT_FILE_PATH_0, INPUT_FILE_PATH_1]; // Replace with your input image file paths\nconst outputImagePaths = [OUTPUT_FILE_PATH_0, OUTPUT_FILE_PATH_0]; // Replace with your output thumbnail file paths\n\ncreateThumbnails(inputImagePaths, outputImagePaths);\n\n// updates here \n// update v1.1.2\n	2024-06-29 16:28:48.168426	88e39a98-56a3-4d25-936a-21dae870d0b3
ff962c0d-869d-4366-82ed-801bff9f8e21	v1.0.0	c++	#include <iostream>\n#include <vector>\n#include <algorithm>\n\n\n\n// Quick Sort\nint partition(std::vector<int>& arr, int low, int high) {\n    int pivot = arr[high];\n    int i = low - 1;\n    for (int j = low; j < high; ++j) {\n        if (arr[j] < pivot) {\n            ++i;\n            std::swap(arr[i], arr[j]);\n        }\n    }\n    std::swap(arr[i + 1], arr[high]);\n    return i + 1;\n}\n\nvoid quickSort(std::vector<int>& arr, int low, int high) {\n    if (low < high) {\n        int pi = partition(arr, low, high);\n        quickSort(arr, low, pi - 1);\n        quickSort(arr, pi + 1, high);\n    }\n}\n\nint main() {\n    std::vector<int> arr1 = {34, 7, 23, 32, 5, 62};\n    std::vector<int> arr2 = arr1;\n    std::vector<int> arr3 = arr1;\n\n    quickSort(arr3, 0, arr3.size() - 1);\n\n\n    std::cout << "Quick Sorted: ";\n    for (int num : arr3) std::cout << num << " ";\n    std::cout << std::endl;\n\n    return 0;\n}\n	2024-06-29 18:28:50.308323	25ba8c0b-e206-475b-a899-ebf6ddb9f593
acb6940d-3a49-41b2-b59c-5b9a8e7e83e1	1.1.1	c++	#include <iostream>\n#include <vector>\n#include <algorithm>\n\n\n// Insertion Sort\nvoid insertionSort(std::vector<int>& arr) {\n    int n = arr.size();\n    for (int i = 1; i < n; ++i) {\n        int key = arr[i];\n        int j = i - 1;\n        while (j >= 0 && arr[j] > key) {\n            arr[j + 1] = arr[j];\n            --j;\n        }\n        arr[j + 1] = key;\n    }\n}\n\n// Quick Sort\nint partition(std::vector<int>& arr, int low, int high) {\n    int pivot = arr[high];\n    int i = low - 1;\n    for (int j = low; j < high; ++j) {\n        if (arr[j] < pivot) {\n            ++i;\n            std::swap(arr[i], arr[j]);\n        }\n    }\n    std::swap(arr[i + 1], arr[high]);\n    return i + 1;\n}\n\nvoid quickSort(std::vector<int>& arr, int low, int high) {\n    if (low < high) {\n        int pi = partition(arr, low, high);\n        quickSort(arr, low, pi - 1);\n        quickSort(arr, pi + 1, high);\n    }\n}\n\nint main() {\n    std::vector<int> arr1 = {34, 7, 23, 32, 5, 62};\n    std::vector<int> arr2 = arr1;\n    std::vector<int> arr3 = arr1;\n\n    insertionSort(arr2);\n    quickSort(arr3, 0, arr3.size() - 1);\n\n    std::cout << "Bubble Sorted: ";\n    for (int num : arr1) std::cout << num << " ";\n    std::cout << std::endl;\n\n    std::cout << "Insertion Sorted: ";\n    for (int num : arr2) std::cout << num << " ";\n    std::cout << std::endl;\n\n    std::cout << "Quick Sorted: ";\n    for (int num : arr3) std::cout << num << " ";\n    std::cout << std::endl;\n\n    return 0;\n}\n	2024-06-29 18:29:22.714617	25ba8c0b-e206-475b-a899-ebf6ddb9f593
de4e2f54-9b34-47b8-836e-a05384700f27	1.1.2	javascript	const fs = require('fs-extra');\nconst yaml = require('yaml');\nconst path = require('path');\n\nconsole.log("version 1.1.2");	2024-06-29 18:35:08.165803	327c8fef-d34c-45e8-aec2-0d226e8347ad
d50ab2b1-b468-4699-9dec-dcc57dd7e6a9	1.1.3	javascript	console.log('v1.1.3')	2024-06-29 18:35:29.164085	327c8fef-d34c-45e8-aec2-0d226e8347ad
df689549-e800-4410-9556-186e9dfdd809	V2	c++	#include <iostream>\n#include <vector>\n#include <queue>\n\n// verions 2\n\n// Merge Two Sorted Arrays\nstd::vector<int> mergeTwoSortedArrays(const std::vector<int>& arr1, const std::vector<int>& arr2) {\n    std::vector<int> result;\n    int i = 0, j = 0;\n\n    while (i < arr1.size() && j < arr2.size()) {\n        if (arr1[i] < arr2[j]) {\n            result.push_back(arr1[i++]);\n        } else {\n            result.push_back(arr2[j++]);\n        }\n    }\n\n    while (i < arr1.size()) {\n        result.push_back(arr1[i++]);\n    }\n\n    while (j < arr2.size()) {\n        result.push_back(arr2[j++]);\n    }\n\n    return result;\n}\n\n// Merge K Sorted Arrays\nstd::vector<int> mergeKSortedArrays(const std::vector<std::vector<int>>& arrays) {\n    auto compare = [](const std::pair<int, std::pair<int, int>>& a, const std::pair<int, std::pair<int, int>>& b) {\n        return a.first > b.first;\n    };\n    \n    std::priority_queue<std::pair<int, std::pair<int, int>>, std::vector<std::pair<int, std::pair<int, int>>>, decltype(compare)> minHeap(compare);\n    std::vector<int> result;\n\n    for (int i = 0; i < arrays.size(); ++i) {\n        if (!arrays[i].empty()) {\n            minHeap.push({arrays[i][0], {i, 0}});\n        }\n    }\n\n    while (!minHeap.empty()) {\n        auto [value, indices] = minHeap.top();\n        minHeap.pop();\n        result.push_back(value);\n        int arrayIndex = indices.first;\n        int elementIndex = indices.second;\n        if (elementIndex + 1 < arrays[arrayIndex].size()) {\n            minHeap.push({arrays[arrayIndex][elementIndex + 1], {arrayIndex, elementIndex + 1}});\n        }\n    }\n\n    return result;\n}\n\nint main() {\n    std::vector<int> arr1 = {1, 4, 7};\n    std::vector<int> arr2 = {2, 5, 8};\n    std::vector<int> arr3 = {3, 6, 9};\n\n    std::vector<std::vector<int>> arrays = {arr1, arr2, arr3};\n\n    std::vector<int> mergedTwo = mergeTwoSortedArrays(arr1, arr2);\n    std::vector<int> mergedK = mergeKSortedArrays(arrays);\n\n    std::cout << "Merged Two Arrays: ";\n    for (int num : mergedTwo) std::cout << num << " ";\n    std::cout << std::endl;\n\n    std::cout << "Merged K Arrays: ";\n    for (int num : mergedK) std::cout << num << " ";\n    std::cout << std::endl;\n\n    return 0;\n}\n	2024-06-29 18:36:04.882628	72ac885d-73d6-4179-a7ca-71bb98cb5486
\.


--
-- Data for Name: program-versions; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public."program-versions" ("programVersionId", version, "programmingLanguage", "sourceCode", "createdAt", "programProgramId") FROM stdin;
\.


--
-- Data for Name: program_version_entity; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.program_version_entity ("programVersionId", version, "programmingLanguage", "sourceCode", "createdAt", "programProgramId") FROM stdin;
\.


--
-- Data for Name: reaction_entity; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.reaction_entity ("reactionId", type, "createdAt", "userId", "programId") FROM stdin;
30ed0b98-8f5a-4feb-b100-51a27b7981d7	like	2024-06-26 17:23:45.067964	0efabb18-5aff-4a06-8a56-ea882a231b6e	88e39a98-56a3-4d25-936a-21dae870d0b3
09d93c93-fbde-42b6-936c-922258084e49	like	2024-06-26 17:33:04.87049	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	88e39a98-56a3-4d25-936a-21dae870d0b3
99071bbf-adda-42ad-a83e-3cce2bc54ba6	like	2024-06-26 17:33:04.874453	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	88e39a98-56a3-4d25-936a-21dae870d0b3
cfd83e0d-1f7b-4b9e-aad3-0c998185fb0a	like	2024-06-26 17:33:04.876929	9e00a085-1e03-4bb5-b18d-65d93f16f743	88e39a98-56a3-4d25-936a-21dae870d0b3
c2c25137-4c2e-4a5d-9025-f15164021fe0	like	2024-06-26 17:33:04.879746	745820cf-14e3-4837-be8a-2f7151ec9131	88e39a98-56a3-4d25-936a-21dae870d0b3
cd699b73-5adc-41e2-be19-dd27fab1bf54	like	2024-06-26 17:33:04.880873	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	88e39a98-56a3-4d25-936a-21dae870d0b3
aaba17de-7e0f-4197-ae62-76fa1394f3b6	like	2024-06-26 17:33:04.881547	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	88e39a98-56a3-4d25-936a-21dae870d0b3
e8dcb312-7858-4c79-8850-133b03831e12	like	2024-06-26 17:33:04.882219	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	88e39a98-56a3-4d25-936a-21dae870d0b3
c1e34d15-0298-4c97-85ac-bc18bacdef29	like	2024-06-26 17:33:04.883039	4ac4c910-d783-48d5-ae41-b542e8cb666f	88e39a98-56a3-4d25-936a-21dae870d0b3
2fdd19f3-fd23-4a68-ae9a-bc40d8d982a2	like	2024-06-26 17:33:04.885906	f927fc08-8f8a-4a0b-adec-d924091dcad1	88e39a98-56a3-4d25-936a-21dae870d0b3
fb8dd91d-319f-4b8c-a6a5-22193c9ba475	like	2024-06-26 17:33:04.888229	b0ed894a-610d-498c-b11f-ed47d2a87b29	88e39a98-56a3-4d25-936a-21dae870d0b3
bd1a81cc-1149-4280-a33a-debedd0c3443	like	2024-06-26 17:33:04.889407	2bebe474-6406-409e-904c-ff7865ac755e	88e39a98-56a3-4d25-936a-21dae870d0b3
36983f02-464e-4964-a76e-883e1740933b	like	2024-06-26 17:33:04.891219	2bdba617-734f-48a5-844c-c7ca5a68781b	88e39a98-56a3-4d25-936a-21dae870d0b3
7b29c90c-6df2-4b76-8b0e-398911aed2a1	like	2024-06-26 17:33:04.891729	7575e78a-a78b-4900-9fb3-b30c925e5f89	88e39a98-56a3-4d25-936a-21dae870d0b3
85775ede-02ca-404a-8e1b-4761eb75abca	dislike	2024-06-26 17:33:04.892116	a96df0df-f4a1-4d82-a655-2f7f94ace896	88e39a98-56a3-4d25-936a-21dae870d0b3
c088c6f1-c31f-48b6-909e-f052a0106ef5	like	2024-06-26 17:33:04.892728	f3c04916-f30d-4360-b465-c5eb262dce94	88e39a98-56a3-4d25-936a-21dae870d0b3
fd819d9c-64e2-415d-a9d3-3c94f67223ec	like	2024-06-26 17:33:04.893285	d1dbec9d-ce36-42b3-a467-0b1512f41545	88e39a98-56a3-4d25-936a-21dae870d0b3
3fc6dcfb-65ac-4ab7-a7e4-734f226e96a9	like	2024-06-26 17:33:04.893718	960823cf-d908-4246-8fa0-0ac6118797ca	88e39a98-56a3-4d25-936a-21dae870d0b3
03ca0a35-5c00-481f-bed9-10f950f048e5	like	2024-06-26 17:33:04.895008	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	88e39a98-56a3-4d25-936a-21dae870d0b3
20e56334-968b-4959-b080-4edc2159f1fc	like	2024-06-26 17:33:04.896066	b0afe2ef-0b3d-481d-9654-f9e67207757d	88e39a98-56a3-4d25-936a-21dae870d0b3
98df3596-6906-453f-aaa4-31171e570235	like	2024-06-26 17:33:04.897043	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	88e39a98-56a3-4d25-936a-21dae870d0b3
38aae755-23ba-4e1c-abb7-5c5ca1c40b07	like	2024-06-26 17:33:04.897626	31c3d5b3-8c7c-4cef-a037-2eccb1839791	88e39a98-56a3-4d25-936a-21dae870d0b3
f6d2ccc7-8c17-4d8b-bbc3-69260dae6f21	dislike	2024-06-26 17:33:04.89806	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	88e39a98-56a3-4d25-936a-21dae870d0b3
6ee97c6d-23c7-409e-b375-932a4e09a546	like	2024-06-26 17:33:04.899386	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	88e39a98-56a3-4d25-936a-21dae870d0b3
1dde0eb0-4a8a-4fe9-8d4e-42e9757d663d	dislike	2024-06-26 17:34:33.098554	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	88e39a98-56a3-4d25-936a-21dae870d0b3
4c25375b-2703-404c-a122-87805e99c7da	like	2024-06-26 17:35:29.642272	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	88e39a98-56a3-4d25-936a-21dae870d0b3
dcf487f3-976c-431f-a6d8-e7ac021b196c	like	2024-06-26 17:36:41.9384	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	327c8fef-d34c-45e8-aec2-0d226e8347ad
c790fd07-4fab-4fa2-8b37-5bd3ed0a634a	like	2024-06-26 17:36:41.943759	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	327c8fef-d34c-45e8-aec2-0d226e8347ad
5ba75e0a-3db8-40e7-9aeb-545d5ae6eab9	like	2024-06-26 17:36:41.946287	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	327c8fef-d34c-45e8-aec2-0d226e8347ad
37ef7eaa-1d36-4fd2-86fb-436f1fcdcba8	dislike	2024-06-26 17:36:41.947811	9e00a085-1e03-4bb5-b18d-65d93f16f743	327c8fef-d34c-45e8-aec2-0d226e8347ad
02a49d80-2eef-49c4-b2fa-92b773d8383e	dislike	2024-06-26 17:36:41.949239	745820cf-14e3-4837-be8a-2f7151ec9131	327c8fef-d34c-45e8-aec2-0d226e8347ad
594094a2-ce5c-4cae-863f-2014c361010d	dislike	2024-06-26 17:36:41.950545	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	327c8fef-d34c-45e8-aec2-0d226e8347ad
8244c5b6-0f7b-4ef7-a869-fff582f883aa	dislike	2024-06-26 17:36:41.952493	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	327c8fef-d34c-45e8-aec2-0d226e8347ad
c4787d07-5b29-4d69-844d-f78ebae65200	dislike	2024-06-26 17:36:41.953866	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	327c8fef-d34c-45e8-aec2-0d226e8347ad
f82063b8-f24a-474f-9b9c-b4f8566dc30a	dislike	2024-06-26 17:36:41.955228	4ac4c910-d783-48d5-ae41-b542e8cb666f	327c8fef-d34c-45e8-aec2-0d226e8347ad
30953c7d-48b9-4a90-9383-29fffbe107a9	dislike	2024-06-26 17:36:41.956745	f927fc08-8f8a-4a0b-adec-d924091dcad1	327c8fef-d34c-45e8-aec2-0d226e8347ad
b9410803-ca0f-4b1c-b480-57b9077935c9	like	2024-06-26 17:36:41.958053	b0ed894a-610d-498c-b11f-ed47d2a87b29	327c8fef-d34c-45e8-aec2-0d226e8347ad
0820d2de-0889-47c4-bd92-0dc6aa90429d	like	2024-06-26 17:36:41.959655	2bebe474-6406-409e-904c-ff7865ac755e	327c8fef-d34c-45e8-aec2-0d226e8347ad
507848e7-d080-4218-98e4-2a01754fcf66	like	2024-06-26 17:36:41.960876	2bdba617-734f-48a5-844c-c7ca5a68781b	327c8fef-d34c-45e8-aec2-0d226e8347ad
53911db0-a860-4ee0-ae63-25249cfe9a26	like	2024-06-26 17:36:41.96193	7575e78a-a78b-4900-9fb3-b30c925e5f89	327c8fef-d34c-45e8-aec2-0d226e8347ad
57449eca-ffa5-4717-996c-66835032249f	dislike	2024-06-26 17:36:41.962792	a96df0df-f4a1-4d82-a655-2f7f94ace896	327c8fef-d34c-45e8-aec2-0d226e8347ad
c572ae9a-ef45-4f73-b625-9241ec4c4507	like	2024-06-26 17:36:41.963772	f3c04916-f30d-4360-b465-c5eb262dce94	327c8fef-d34c-45e8-aec2-0d226e8347ad
0eccf31d-3db9-4f77-bdea-f0dfe17a58a7	like	2024-06-26 17:36:41.964563	d1dbec9d-ce36-42b3-a467-0b1512f41545	327c8fef-d34c-45e8-aec2-0d226e8347ad
8a032a8a-a68e-4db8-8572-409b42913e66	like	2024-06-26 17:36:41.96543	960823cf-d908-4246-8fa0-0ac6118797ca	327c8fef-d34c-45e8-aec2-0d226e8347ad
7811b884-bdc4-4af8-885e-cfc35004e6b3	like	2024-06-26 17:36:41.966157	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	327c8fef-d34c-45e8-aec2-0d226e8347ad
686efb6c-61d0-436c-8299-04a0f007a083	like	2024-06-26 17:36:41.966944	0efabb18-5aff-4a06-8a56-ea882a231b6e	327c8fef-d34c-45e8-aec2-0d226e8347ad
fb3095fa-03d5-4b62-a1c1-e98290894ca7	like	2024-06-26 17:36:41.968196	b0afe2ef-0b3d-481d-9654-f9e67207757d	327c8fef-d34c-45e8-aec2-0d226e8347ad
c026f835-3bc3-4317-9383-3b114cd9e436	like	2024-06-26 17:36:41.970099	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	327c8fef-d34c-45e8-aec2-0d226e8347ad
c37aa7df-d291-4cd0-b19d-3c183a597757	like	2024-06-26 17:36:41.972338	31c3d5b3-8c7c-4cef-a037-2eccb1839791	327c8fef-d34c-45e8-aec2-0d226e8347ad
5e48a72a-ab16-4445-aa3f-d339cec5639e	dislike	2024-06-26 17:36:41.972728	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	327c8fef-d34c-45e8-aec2-0d226e8347ad
da4ed173-299d-4d5e-bb86-dd6ec5bf05a1	like	2024-06-26 17:36:41.97338	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	327c8fef-d34c-45e8-aec2-0d226e8347ad
a77f41db-4a4a-4e50-bc0e-05501d662c8a	dislike	2024-06-26 17:36:41.973707	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	327c8fef-d34c-45e8-aec2-0d226e8347ad
15aa22cb-9a06-4c5c-9191-1d2b7207726c	like	2024-06-26 17:38:19.594632	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	20ff146f-bd26-4272-8dce-016480cf0455
a910eaad-a397-4755-8464-bbaa598aa18a	like	2024-06-26 17:38:19.597467	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	20ff146f-bd26-4272-8dce-016480cf0455
bb89d86d-2f6a-4938-a5a4-38c172f5bd22	like	2024-06-26 17:38:19.598822	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	20ff146f-bd26-4272-8dce-016480cf0455
836b4a8f-7973-48ed-b5f4-1a71457fb9fa	dislike	2024-06-26 17:38:19.599998	9e00a085-1e03-4bb5-b18d-65d93f16f743	20ff146f-bd26-4272-8dce-016480cf0455
5e6e76b0-d10c-4522-9756-422debc2a121	dislike	2024-06-26 17:38:19.600852	745820cf-14e3-4837-be8a-2f7151ec9131	20ff146f-bd26-4272-8dce-016480cf0455
22ab729c-4dfa-4abe-86e5-cf1769b728c4	like	2024-06-26 17:38:19.601594	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	20ff146f-bd26-4272-8dce-016480cf0455
746cf488-b23f-4ba9-b445-0e4a75318914	like	2024-06-26 17:38:19.602563	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	20ff146f-bd26-4272-8dce-016480cf0455
223d8674-2bec-4055-9c22-7ff6ad4abda4	like	2024-06-26 17:38:19.603718	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	20ff146f-bd26-4272-8dce-016480cf0455
758fabd1-fb99-479a-978d-9698054c359c	dislike	2024-06-26 17:38:19.604895	4ac4c910-d783-48d5-ae41-b542e8cb666f	20ff146f-bd26-4272-8dce-016480cf0455
0c9c4cda-a358-414e-bd1f-03e45dbdb662	dislike	2024-06-26 17:38:19.606089	f927fc08-8f8a-4a0b-adec-d924091dcad1	20ff146f-bd26-4272-8dce-016480cf0455
de880e01-615c-47c9-8ed9-d22d9d6817d2	like	2024-06-26 17:38:19.607291	b0ed894a-610d-498c-b11f-ed47d2a87b29	20ff146f-bd26-4272-8dce-016480cf0455
a04968a4-692e-4077-b302-6368fe9c0154	like	2024-06-26 17:38:19.608621	2bebe474-6406-409e-904c-ff7865ac755e	20ff146f-bd26-4272-8dce-016480cf0455
51173d6b-72a4-44ea-954e-e8ab2d29afb0	like	2024-06-26 17:38:19.609873	2bdba617-734f-48a5-844c-c7ca5a68781b	20ff146f-bd26-4272-8dce-016480cf0455
19a69b3e-5699-4b1f-95aa-606d0724a2c2	like	2024-06-26 17:38:19.610672	7575e78a-a78b-4900-9fb3-b30c925e5f89	20ff146f-bd26-4272-8dce-016480cf0455
d1a3ddc9-1807-4a44-9722-2fb41864daf5	dislike	2024-06-26 17:38:19.611485	a96df0df-f4a1-4d82-a655-2f7f94ace896	20ff146f-bd26-4272-8dce-016480cf0455
479540d8-7809-4a35-b576-635cb4f62080	like	2024-06-26 17:38:19.612226	f3c04916-f30d-4360-b465-c5eb262dce94	20ff146f-bd26-4272-8dce-016480cf0455
a609f7f2-f9c0-4708-84b9-6de86ef7091f	like	2024-06-26 17:38:19.612961	d1dbec9d-ce36-42b3-a467-0b1512f41545	20ff146f-bd26-4272-8dce-016480cf0455
4a40e866-10bf-471c-8d12-ab7bc653dbb7	like	2024-06-26 17:38:19.613698	960823cf-d908-4246-8fa0-0ac6118797ca	20ff146f-bd26-4272-8dce-016480cf0455
7f4b55c4-08ae-4719-910d-d09af4e0fb71	like	2024-06-26 17:38:19.614372	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	20ff146f-bd26-4272-8dce-016480cf0455
ab3af9c5-df5e-4cbc-9041-58391ec3eba8	like	2024-06-26 17:38:19.61499	0efabb18-5aff-4a06-8a56-ea882a231b6e	20ff146f-bd26-4272-8dce-016480cf0455
95e767f3-0e53-499c-bc78-bdfbab3ab08c	like	2024-06-26 17:38:19.615659	b0afe2ef-0b3d-481d-9654-f9e67207757d	20ff146f-bd26-4272-8dce-016480cf0455
fdd37fca-8eb8-40b9-8d4a-62df9879bbb7	like	2024-06-26 17:38:19.617212	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	20ff146f-bd26-4272-8dce-016480cf0455
4e046121-92c8-4a27-a0b2-708bef105c42	like	2024-06-26 17:38:19.618104	31c3d5b3-8c7c-4cef-a037-2eccb1839791	20ff146f-bd26-4272-8dce-016480cf0455
01e79804-bdcd-488d-8d59-ce93b1d83504	dislike	2024-06-26 17:38:19.61885	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	20ff146f-bd26-4272-8dce-016480cf0455
65a5a72d-1f12-41df-a275-156622a60adb	like	2024-06-26 17:38:19.619881	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	20ff146f-bd26-4272-8dce-016480cf0455
b6a481d9-dbae-4295-af01-e7f2b14ee9ab	dislike	2024-06-26 17:38:19.62046	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	20ff146f-bd26-4272-8dce-016480cf0455
ae3a2f7d-ade7-469c-8426-e48848291e7d	like	2024-06-26 17:39:05.664159	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	b85d1b4b-f01d-41f8-b273-ac2816c566b5
a8e8b1b6-482e-4de6-afc3-831a68123f61	like	2024-06-26 17:39:05.666358	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	b85d1b4b-f01d-41f8-b273-ac2816c566b5
dc7d0638-6356-422b-b21a-5bfffe6299ef	like	2024-06-26 17:39:05.667318	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	b85d1b4b-f01d-41f8-b273-ac2816c566b5
4ee487ce-5a78-4652-9697-f8a56f401f72	dislike	2024-06-26 17:39:05.668433	9e00a085-1e03-4bb5-b18d-65d93f16f743	b85d1b4b-f01d-41f8-b273-ac2816c566b5
79367efd-0c60-4f0e-9211-4b96e1a29323	dislike	2024-06-26 17:39:05.669415	745820cf-14e3-4837-be8a-2f7151ec9131	b85d1b4b-f01d-41f8-b273-ac2816c566b5
aa1af812-34c5-41c6-85e5-fa7f98f25747	like	2024-06-26 17:39:05.670905	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	b85d1b4b-f01d-41f8-b273-ac2816c566b5
52cbdc36-f2b3-4cca-ac99-f631677687fd	like	2024-06-26 17:39:05.672982	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	b85d1b4b-f01d-41f8-b273-ac2816c566b5
a7e7220e-2e3d-4bcc-b456-e58ab57f975c	like	2024-06-26 17:39:05.67439	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	b85d1b4b-f01d-41f8-b273-ac2816c566b5
1cb4c580-ddf4-42aa-aba0-391478529969	dislike	2024-06-26 17:39:05.675719	4ac4c910-d783-48d5-ae41-b542e8cb666f	b85d1b4b-f01d-41f8-b273-ac2816c566b5
16dde338-fdcf-4e72-9a3d-bcf92d529feb	dislike	2024-06-26 17:39:05.677071	f927fc08-8f8a-4a0b-adec-d924091dcad1	b85d1b4b-f01d-41f8-b273-ac2816c566b5
44801699-c918-4000-a8a7-a4ee784357c9	like	2024-06-26 17:39:05.678602	b0ed894a-610d-498c-b11f-ed47d2a87b29	b85d1b4b-f01d-41f8-b273-ac2816c566b5
6c87168b-d997-4b01-9c8e-8692a3b808ec	like	2024-06-26 17:39:05.68045	2bebe474-6406-409e-904c-ff7865ac755e	b85d1b4b-f01d-41f8-b273-ac2816c566b5
1e2d5d67-1414-49ac-aca8-197c5e1e6b1f	like	2024-06-26 17:39:05.682356	2bdba617-734f-48a5-844c-c7ca5a68781b	b85d1b4b-f01d-41f8-b273-ac2816c566b5
02ebdf61-8eca-4337-b37c-2366ee078032	like	2024-06-26 17:39:05.683842	7575e78a-a78b-4900-9fb3-b30c925e5f89	b85d1b4b-f01d-41f8-b273-ac2816c566b5
42b9a38a-f7b9-40c2-8c6b-713d4d6ea107	dislike	2024-06-26 17:39:05.685251	a96df0df-f4a1-4d82-a655-2f7f94ace896	b85d1b4b-f01d-41f8-b273-ac2816c566b5
6fc3ddfc-7678-44ee-be38-70ef90d41832	like	2024-06-26 17:39:05.686523	f3c04916-f30d-4360-b465-c5eb262dce94	b85d1b4b-f01d-41f8-b273-ac2816c566b5
c2db2758-9077-4ca8-847f-6c7b078d7a53	like	2024-06-26 17:39:05.687995	d1dbec9d-ce36-42b3-a467-0b1512f41545	b85d1b4b-f01d-41f8-b273-ac2816c566b5
369d9973-7e92-4afa-a85f-e1d22a0d3ddc	like	2024-06-26 17:39:05.689462	960823cf-d908-4246-8fa0-0ac6118797ca	b85d1b4b-f01d-41f8-b273-ac2816c566b5
395f1acf-4cbf-4e2c-97a5-d505dea32d8f	like	2024-06-26 17:39:42.44478	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	dd7734cc-3f4f-48ac-bcea-f38a122ab792
ea83539e-cf3e-4012-b604-96422e80f02d	like	2024-06-26 17:39:42.448343	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	dd7734cc-3f4f-48ac-bcea-f38a122ab792
55100096-abfb-49af-be6e-5201ca7f9c59	like	2024-06-26 17:39:42.450053	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	dd7734cc-3f4f-48ac-bcea-f38a122ab792
77415ebe-b5d0-457b-9e10-61a37a25891d	dislike	2024-06-26 17:39:42.451858	9e00a085-1e03-4bb5-b18d-65d93f16f743	dd7734cc-3f4f-48ac-bcea-f38a122ab792
d76597fa-37ab-4a98-a82c-8bf21074905b	dislike	2024-06-26 17:39:42.453825	745820cf-14e3-4837-be8a-2f7151ec9131	dd7734cc-3f4f-48ac-bcea-f38a122ab792
a2bc3b3f-c4d9-4d13-bf18-01a6321ff406	like	2024-06-26 17:39:42.455114	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	dd7734cc-3f4f-48ac-bcea-f38a122ab792
01f93a06-e852-4694-8035-e30af26a3596	like	2024-06-26 17:39:42.456221	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	dd7734cc-3f4f-48ac-bcea-f38a122ab792
4e256058-5da6-4d86-876e-6e6ef1799a59	like	2024-06-26 17:39:42.456963	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	dd7734cc-3f4f-48ac-bcea-f38a122ab792
e5516311-8c15-434b-a69a-05c73d115949	dislike	2024-06-26 17:39:42.458769	4ac4c910-d783-48d5-ae41-b542e8cb666f	dd7734cc-3f4f-48ac-bcea-f38a122ab792
a3132470-a47e-4e00-8fc7-151e5cefaf67	dislike	2024-06-26 17:39:42.46025	f927fc08-8f8a-4a0b-adec-d924091dcad1	dd7734cc-3f4f-48ac-bcea-f38a122ab792
714d191d-df4f-4d1b-85db-9bcd8b34ed80	like	2024-06-26 17:39:42.461423	b0ed894a-610d-498c-b11f-ed47d2a87b29	dd7734cc-3f4f-48ac-bcea-f38a122ab792
15dfb46b-d3cc-41fb-9b33-66cc7dad21ca	like	2024-06-26 17:39:42.462255	2bebe474-6406-409e-904c-ff7865ac755e	dd7734cc-3f4f-48ac-bcea-f38a122ab792
0ff01473-651b-41d1-8b67-8e5e1800945c	like	2024-06-26 17:39:42.462973	2bdba617-734f-48a5-844c-c7ca5a68781b	dd7734cc-3f4f-48ac-bcea-f38a122ab792
34776b8f-525d-4426-97b3-17a620e5e8cd	like	2024-06-26 17:39:42.463819	7575e78a-a78b-4900-9fb3-b30c925e5f89	dd7734cc-3f4f-48ac-bcea-f38a122ab792
5be7c205-9007-4697-9739-8023fd8fa02b	dislike	2024-06-26 17:39:42.46458	a96df0df-f4a1-4d82-a655-2f7f94ace896	dd7734cc-3f4f-48ac-bcea-f38a122ab792
2ca1693e-1243-4bf7-be1d-1296ba6d0828	like	2024-06-26 17:39:42.46532	f3c04916-f30d-4360-b465-c5eb262dce94	dd7734cc-3f4f-48ac-bcea-f38a122ab792
661c9116-1533-492b-b562-65b63dcce1ff	like	2024-06-26 17:39:42.465954	d1dbec9d-ce36-42b3-a467-0b1512f41545	dd7734cc-3f4f-48ac-bcea-f38a122ab792
2ec41284-4d4c-4bd0-a948-150e1bb110ad	like	2024-06-26 17:39:42.466577	960823cf-d908-4246-8fa0-0ac6118797ca	dd7734cc-3f4f-48ac-bcea-f38a122ab792
8cc0390c-182e-4fef-aa2f-d93e9d5a03a4	like	2024-06-26 17:39:42.467183	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	dd7734cc-3f4f-48ac-bcea-f38a122ab792
2c3d4ca1-ac63-4b07-ae53-7e3b26762b06	like	2024-06-26 17:39:42.467796	0efabb18-5aff-4a06-8a56-ea882a231b6e	dd7734cc-3f4f-48ac-bcea-f38a122ab792
9b424bcc-1710-4617-8189-ffbf5292630f	like	2024-06-26 17:39:42.468807	b0afe2ef-0b3d-481d-9654-f9e67207757d	dd7734cc-3f4f-48ac-bcea-f38a122ab792
03b98978-d6ff-4ff4-91d0-93a21552de67	like	2024-06-26 17:39:42.47008	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	dd7734cc-3f4f-48ac-bcea-f38a122ab792
da99b189-9604-477d-b7a6-286832d86f65	like	2024-06-26 17:39:42.470795	31c3d5b3-8c7c-4cef-a037-2eccb1839791	dd7734cc-3f4f-48ac-bcea-f38a122ab792
75ad8703-9bfa-4ed8-8674-a7a69202c200	dislike	2024-06-26 17:39:42.471426	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	dd7734cc-3f4f-48ac-bcea-f38a122ab792
10594eee-4bd0-47c7-a8c3-45f27aec3245	like	2024-06-26 17:39:42.472188	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	dd7734cc-3f4f-48ac-bcea-f38a122ab792
e03be0a5-fc07-487d-b56e-155854543a91	dislike	2024-06-26 17:39:42.472828	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	dd7734cc-3f4f-48ac-bcea-f38a122ab792
f657964b-cb68-48df-8143-f5dd82bfcda0	like	2024-06-26 17:40:28.528389	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	4997a34d-85e4-4763-83e5-2dc39be7fdd9
40fde0be-bb2e-4845-8107-fe99e924d7d6	like	2024-06-26 17:40:28.53257	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	4997a34d-85e4-4763-83e5-2dc39be7fdd9
fe95cfea-1943-4423-9625-f305a90c8d9b	like	2024-06-26 17:40:28.53426	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	4997a34d-85e4-4763-83e5-2dc39be7fdd9
b97054a1-3664-4dad-b8b5-58dca34fc77b	dislike	2024-06-26 17:40:28.535326	9e00a085-1e03-4bb5-b18d-65d93f16f743	4997a34d-85e4-4763-83e5-2dc39be7fdd9
efb65e61-1477-4299-8191-ea88d3e23624	dislike	2024-06-26 17:40:28.5365	745820cf-14e3-4837-be8a-2f7151ec9131	4997a34d-85e4-4763-83e5-2dc39be7fdd9
c6f1d02e-9441-40cc-a636-cbfd407685ed	dislike	2024-06-26 17:40:28.537355	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	4997a34d-85e4-4763-83e5-2dc39be7fdd9
380f05ee-2823-491c-bd64-ede72f525378	dislike	2024-06-26 17:40:28.538555	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	4997a34d-85e4-4763-83e5-2dc39be7fdd9
4530c777-bc59-4b46-aa80-6543b6642b87	dislike	2024-06-26 17:40:28.5395	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	4997a34d-85e4-4763-83e5-2dc39be7fdd9
838f1b59-05f6-4bde-a805-3f642ff92835	dislike	2024-06-26 17:40:28.540348	4ac4c910-d783-48d5-ae41-b542e8cb666f	4997a34d-85e4-4763-83e5-2dc39be7fdd9
577ab24b-7ece-4171-a329-7b5e465245e5	dislike	2024-06-26 17:40:28.541112	f927fc08-8f8a-4a0b-adec-d924091dcad1	4997a34d-85e4-4763-83e5-2dc39be7fdd9
cfc7e92f-8c08-415a-a2f1-d9275a196033	dislike	2024-06-26 17:40:28.541848	b0ed894a-610d-498c-b11f-ed47d2a87b29	4997a34d-85e4-4763-83e5-2dc39be7fdd9
e87be117-1f55-4297-82fe-0f81ebd54fe1	dislike	2024-06-26 17:40:28.542576	2bebe474-6406-409e-904c-ff7865ac755e	4997a34d-85e4-4763-83e5-2dc39be7fdd9
84f772f0-f1a0-4664-a076-56fa53177cde	dislike	2024-06-26 17:40:28.54337	2bdba617-734f-48a5-844c-c7ca5a68781b	4997a34d-85e4-4763-83e5-2dc39be7fdd9
5ece5a3c-91cf-42c2-b2ee-1a0019feeae1	like	2024-06-26 17:40:28.544039	7575e78a-a78b-4900-9fb3-b30c925e5f89	4997a34d-85e4-4763-83e5-2dc39be7fdd9
7511e641-4cb3-4ecc-9634-339ce446a945	dislike	2024-06-26 17:40:28.544773	a96df0df-f4a1-4d82-a655-2f7f94ace896	4997a34d-85e4-4763-83e5-2dc39be7fdd9
e2d39c27-0787-4c19-b5f2-6d20d794dc9f	like	2024-06-26 17:40:28.545571	f3c04916-f30d-4360-b465-c5eb262dce94	4997a34d-85e4-4763-83e5-2dc39be7fdd9
66e9be8e-4906-4543-aee7-fb190d8ad481	like	2024-06-26 17:40:28.546286	d1dbec9d-ce36-42b3-a467-0b1512f41545	4997a34d-85e4-4763-83e5-2dc39be7fdd9
d5a5dc67-4b1e-4b65-9d99-5c4f0eae3301	like	2024-06-26 17:40:28.547121	960823cf-d908-4246-8fa0-0ac6118797ca	4997a34d-85e4-4763-83e5-2dc39be7fdd9
07672646-b933-4900-bd45-d67cf39f3498	like	2024-06-26 17:40:28.547864	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	4997a34d-85e4-4763-83e5-2dc39be7fdd9
2de0c89d-671f-462c-9958-931acb643c5c	like	2024-06-26 17:40:28.548504	0efabb18-5aff-4a06-8a56-ea882a231b6e	4997a34d-85e4-4763-83e5-2dc39be7fdd9
fabb6f39-9dba-402e-9a78-dcb224e0b3bf	like	2024-06-26 17:40:28.549022	b0afe2ef-0b3d-481d-9654-f9e67207757d	4997a34d-85e4-4763-83e5-2dc39be7fdd9
bba6649c-1e6a-4104-93e8-bb6beee56cb6	like	2024-06-26 17:40:28.549971	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	4997a34d-85e4-4763-83e5-2dc39be7fdd9
dcde8043-b2d8-4f62-8deb-8b0d58a8b5e0	like	2024-06-26 17:40:28.5505	31c3d5b3-8c7c-4cef-a037-2eccb1839791	4997a34d-85e4-4763-83e5-2dc39be7fdd9
cf1e2976-5d63-4c35-be71-d7832263c4d7	dislike	2024-06-26 17:40:28.551104	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	4997a34d-85e4-4763-83e5-2dc39be7fdd9
f9d3ca57-d875-4cac-94a4-7efedcb56796	like	2024-06-26 17:40:28.55191	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	4997a34d-85e4-4763-83e5-2dc39be7fdd9
37eae6cd-faba-4982-96ef-9f94f71add85	dislike	2024-06-26 17:40:28.552345	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	4997a34d-85e4-4763-83e5-2dc39be7fdd9
5b4dc872-34b7-47ee-85ca-a4fa91a5db58	like	2024-06-26 17:41:00.743799	f3c04916-f30d-4360-b465-c5eb262dce94	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
f7c6ef0f-70d8-495c-97f9-935f8670b6e4	like	2024-06-26 17:41:00.749578	d1dbec9d-ce36-42b3-a467-0b1512f41545	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
99dd61a2-d3bf-47cc-b8a5-328c4951086e	like	2024-06-26 17:41:00.752025	960823cf-d908-4246-8fa0-0ac6118797ca	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
e57fd92a-b1be-4caf-bb48-c2479c361d45	like	2024-06-26 17:41:00.754494	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
3b5bd54e-6d8c-42e8-92d5-72a0673abab6	like	2024-06-26 17:41:00.756577	0efabb18-5aff-4a06-8a56-ea882a231b6e	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
3a20cb02-fee2-4b01-839b-c0f21e2403cb	like	2024-06-26 17:41:00.75853	b0afe2ef-0b3d-481d-9654-f9e67207757d	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
2f4f6a48-a7f3-4aa5-8e31-49d486ea78d8	like	2024-06-26 17:41:00.761008	2bdba617-734f-48a5-844c-c7ca5a68781b	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
43065709-f336-41f2-96d2-9049f4389934	like	2024-06-26 17:41:00.763351	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
83e6476b-4f28-440c-b1e4-a24d7e8fc8ef	like	2024-06-26 17:41:00.765473	31c3d5b3-8c7c-4cef-a037-2eccb1839791	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
667f6dbb-394c-48b7-bc9b-cd351d771065	dislike	2024-06-26 17:41:00.766953	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
20ee30bd-c31d-4a0f-99c8-f48d25250eac	like	2024-06-26 17:41:00.768036	7575e78a-a78b-4900-9fb3-b30c925e5f89	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
a6ba6c55-9ffe-4e65-b144-50ea3bcc4b1b	like	2024-06-26 17:41:00.768866	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
4f2a1d7c-a1aa-4e70-9f44-55af0a0cbf31	dislike	2024-06-26 17:41:00.769446	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	2556c842-c8b7-4e31-8e7b-dae4fd49b6f8
bc82a9b4-3996-4a97-9463-cbc399f631b6	like	2024-06-26 17:41:40.967695	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	25ba8c0b-e206-475b-a899-ebf6ddb9f593
213b6538-1ea3-4ad5-9818-4289cb09b65d	like	2024-06-26 17:41:40.972442	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	25ba8c0b-e206-475b-a899-ebf6ddb9f593
483e0a37-3ca1-4dad-9dc1-68f422735546	like	2024-06-26 17:41:40.974282	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	25ba8c0b-e206-475b-a899-ebf6ddb9f593
ebba0fbc-3a99-4bd5-82f2-2b9dd4da5d4f	dislike	2024-06-26 17:41:40.975947	9e00a085-1e03-4bb5-b18d-65d93f16f743	25ba8c0b-e206-475b-a899-ebf6ddb9f593
aaffa926-0aa1-4176-a20f-a9375d602e52	dislike	2024-06-26 17:41:40.977399	745820cf-14e3-4837-be8a-2f7151ec9131	25ba8c0b-e206-475b-a899-ebf6ddb9f593
30d0ead1-9636-4cfa-997c-438a10820bd5	dislike	2024-06-26 17:41:40.979129	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	25ba8c0b-e206-475b-a899-ebf6ddb9f593
de1a5120-c1da-4136-9eeb-ec518b9875c5	dislike	2024-06-26 17:41:40.98081	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	25ba8c0b-e206-475b-a899-ebf6ddb9f593
dea04de2-3256-42f1-b93f-e6be92fc22fd	dislike	2024-06-26 17:41:40.983135	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	25ba8c0b-e206-475b-a899-ebf6ddb9f593
f236b0f9-9263-40b4-99e5-4551a14ef9d4	dislike	2024-06-26 17:41:40.985623	4ac4c910-d783-48d5-ae41-b542e8cb666f	25ba8c0b-e206-475b-a899-ebf6ddb9f593
77ace322-43e5-435e-a179-b8ea4571a695	dislike	2024-06-26 17:41:40.987173	f927fc08-8f8a-4a0b-adec-d924091dcad1	25ba8c0b-e206-475b-a899-ebf6ddb9f593
842bc1ae-ce3f-4437-a7a7-f7710f491206	dislike	2024-06-26 17:41:40.98836	b0ed894a-610d-498c-b11f-ed47d2a87b29	25ba8c0b-e206-475b-a899-ebf6ddb9f593
1693ec92-6bd6-4c40-891e-b8be5f0985a3	dislike	2024-06-26 17:41:40.989158	2bebe474-6406-409e-904c-ff7865ac755e	25ba8c0b-e206-475b-a899-ebf6ddb9f593
82c15095-729f-4a07-b759-b7e8b00dcbed	dislike	2024-06-26 17:41:40.989812	2bdba617-734f-48a5-844c-c7ca5a68781b	25ba8c0b-e206-475b-a899-ebf6ddb9f593
e3f5984b-8a0c-4052-8643-599851649701	like	2024-06-26 17:41:40.990262	7575e78a-a78b-4900-9fb3-b30c925e5f89	25ba8c0b-e206-475b-a899-ebf6ddb9f593
2e41871e-c55a-4c39-96c4-d9999268bba3	dislike	2024-06-26 17:41:40.990671	a96df0df-f4a1-4d82-a655-2f7f94ace896	25ba8c0b-e206-475b-a899-ebf6ddb9f593
5ed29bbc-f83b-4b8f-ac81-87421c87f6ad	like	2024-06-26 17:42:53.443158	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
b5a04d0c-f16d-4aea-956d-8b6f5f805383	like	2024-06-26 17:42:53.447564	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
5fded05b-1e6b-4e25-b55f-ea8940bf1ad8	like	2024-06-26 17:42:53.449447	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
a12d1d27-f647-433e-8e69-fa589d1a38c6	dislike	2024-06-26 17:42:53.451445	9e00a085-1e03-4bb5-b18d-65d93f16f743	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
bbae1d88-bfe8-4574-b329-b3e4edc2ef01	dislike	2024-06-26 17:42:53.452797	745820cf-14e3-4837-be8a-2f7151ec9131	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
96200a13-b7a7-4b0c-82f6-7a1b85396ac3	dislike	2024-06-26 17:42:53.455514	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
6e4f038d-8b97-418b-89fd-78d18b195eca	dislike	2024-06-26 17:42:53.457396	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
0d7192e2-a02c-4698-8181-2b8976483bfd	dislike	2024-06-26 17:42:53.458518	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
0e83888b-1eb8-4d48-954b-624fe16878b2	dislike	2024-06-26 17:42:53.459522	4ac4c910-d783-48d5-ae41-b542e8cb666f	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
403494cb-6b52-426b-af73-76a677223c31	dislike	2024-06-26 17:42:53.460987	f927fc08-8f8a-4a0b-adec-d924091dcad1	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
bdca8c06-9817-46bd-aee2-ff3f39d8f17e	dislike	2024-06-26 17:42:53.463032	b0ed894a-610d-498c-b11f-ed47d2a87b29	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
d9f171da-b242-44f2-994d-ae569a7fdcb7	dislike	2024-06-26 17:42:53.464348	2bebe474-6406-409e-904c-ff7865ac755e	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
9102c427-8e13-4f94-a09e-edf191d6ab95	dislike	2024-06-26 17:42:53.465891	2bdba617-734f-48a5-844c-c7ca5a68781b	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
b097c357-50c0-449e-9672-d8655e858965	like	2024-06-26 17:42:53.466997	7575e78a-a78b-4900-9fb3-b30c925e5f89	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
fea5f2e2-9ddf-4b07-abc0-eae1fffb47cb	dislike	2024-06-26 17:42:53.468042	a96df0df-f4a1-4d82-a655-2f7f94ace896	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
b6170217-ba62-4711-bdc9-05828cdd4f58	dislike	2024-06-26 17:42:53.468846	f3c04916-f30d-4360-b465-c5eb262dce94	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
f93fc93c-3ac8-4168-8caf-7c8e7353f58e	dislike	2024-06-26 17:42:53.46976	d1dbec9d-ce36-42b3-a467-0b1512f41545	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
116e39b7-a9f2-4f11-bbed-cb1039e0247a	dislike	2024-06-26 17:42:53.47063	960823cf-d908-4246-8fa0-0ac6118797ca	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
8866d6ca-9d73-471c-97f2-4442b7917023	dislike	2024-06-26 17:42:53.471767	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
f4b4d4c5-a4d9-4af9-9b5c-25713f2bc1a6	dislike	2024-06-26 17:42:53.472242	0efabb18-5aff-4a06-8a56-ea882a231b6e	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
7cf574ed-0e6e-47dc-bed3-668be0d3a016	dislike	2024-06-26 17:42:53.472667	b0afe2ef-0b3d-481d-9654-f9e67207757d	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
6a0bbc67-3fda-4a40-a634-017be06b885a	like	2024-06-26 17:42:53.473698	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
67798b90-7c16-4105-8b23-66bf5335f523	like	2024-06-26 17:42:53.474131	31c3d5b3-8c7c-4cef-a037-2eccb1839791	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
7ef4346b-7b25-4edc-b324-dd621fce561d	dislike	2024-06-26 17:42:53.474519	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
a66b7e44-6643-4e41-89b4-62c2be67ab59	like	2024-06-26 17:42:53.475293	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
5083da55-04ff-4e63-9c3b-badfb2a86373	dislike	2024-06-26 17:42:53.475826	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	8fe11bba-6a07-4c9d-bafb-2d5682a8444e
b434f1de-b761-496b-b70e-cc0e4aeb2f7a	like	2024-06-26 17:44:00.05639	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	72ac885d-73d6-4179-a7ca-71bb98cb5486
b2b50bcd-5217-469b-b247-7b2e63b9c3a1	like	2024-06-26 17:44:00.060505	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	72ac885d-73d6-4179-a7ca-71bb98cb5486
3ebc6cfa-9c56-4f70-b4c9-3f4fed157eef	like	2024-06-26 17:44:00.061834	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	72ac885d-73d6-4179-a7ca-71bb98cb5486
3a392735-c682-40e7-976a-7c4232a27932	dislike	2024-06-26 17:44:00.063247	9e00a085-1e03-4bb5-b18d-65d93f16f743	72ac885d-73d6-4179-a7ca-71bb98cb5486
e4c543bf-bb92-4563-af5b-932e3172fe2c	dislike	2024-06-26 17:44:00.064396	745820cf-14e3-4837-be8a-2f7151ec9131	72ac885d-73d6-4179-a7ca-71bb98cb5486
a44b861d-5837-468d-8013-7f70f5a30229	dislike	2024-06-26 17:44:00.06566	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	72ac885d-73d6-4179-a7ca-71bb98cb5486
bcc7584a-34e6-4707-a0f6-87de687b3183	dislike	2024-06-26 17:44:00.066862	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	72ac885d-73d6-4179-a7ca-71bb98cb5486
33ee12ef-5d74-485a-86ba-fe4e46dc44f9	dislike	2024-06-26 17:44:00.068467	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	72ac885d-73d6-4179-a7ca-71bb98cb5486
2dbee02f-8efd-424e-82a4-ccb6a8fc5815	dislike	2024-06-26 17:44:00.069846	4ac4c910-d783-48d5-ae41-b542e8cb666f	72ac885d-73d6-4179-a7ca-71bb98cb5486
652a472a-677d-4319-8fd9-568e8985ab01	like	2024-06-26 17:44:29.62719	a82ca232-27f5-4edd-a1d8-4678f55e8c8b	b0d45f2b-2442-48cd-8911-591f4fcf0be7
8f65de30-af27-4ce5-8f41-608977e569ab	like	2024-06-26 17:44:29.630536	fcbe60a2-78a6-4f4c-951f-da6422cb80c3	b0d45f2b-2442-48cd-8911-591f4fcf0be7
0e13f9e2-6e0a-4ce5-8ae5-c7c8da66a6e4	like	2024-06-26 17:44:29.632635	57d296e1-7af7-4cfc-afd2-7bc6352a65e6	b0d45f2b-2442-48cd-8911-591f4fcf0be7
a219806c-17ec-4f61-954e-d10ac3ae738f	dislike	2024-06-26 17:44:29.634213	9e00a085-1e03-4bb5-b18d-65d93f16f743	b0d45f2b-2442-48cd-8911-591f4fcf0be7
c0dab3f8-3158-4ec7-b3c6-fe9e57ce0c0d	dislike	2024-06-26 17:44:29.635691	745820cf-14e3-4837-be8a-2f7151ec9131	b0d45f2b-2442-48cd-8911-591f4fcf0be7
23902695-acbc-4699-8c2f-34d67543d34b	dislike	2024-06-26 17:44:29.637052	f8c6500d-bbf6-4c88-959c-c67c7e572fc0	b0d45f2b-2442-48cd-8911-591f4fcf0be7
bf52e7ac-6fbb-405a-a53c-b9aa353eb25e	dislike	2024-06-26 17:44:29.638729	c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	b0d45f2b-2442-48cd-8911-591f4fcf0be7
82edb32f-9bf8-495d-8a40-c438eb7b1595	dislike	2024-06-26 17:44:29.640273	7472ab8a-901e-4dac-a330-9bbe4eda5a5a	b0d45f2b-2442-48cd-8911-591f4fcf0be7
70ac8cf3-ee8c-4007-8d54-343bdc54b47f	dislike	2024-06-26 17:44:29.642569	4ac4c910-d783-48d5-ae41-b542e8cb666f	b0d45f2b-2442-48cd-8911-591f4fcf0be7
71fc5cb3-cc70-4c21-ba6c-484f7ef12caf	dislike	2024-06-26 17:44:29.64406	f927fc08-8f8a-4a0b-adec-d924091dcad1	b0d45f2b-2442-48cd-8911-591f4fcf0be7
88020cd2-d6ae-4cf0-aae1-2cc06016d9b6	dislike	2024-06-26 17:44:29.645218	b0ed894a-610d-498c-b11f-ed47d2a87b29	b0d45f2b-2442-48cd-8911-591f4fcf0be7
9ff378f5-1f00-4929-bf91-690165668aa6	dislike	2024-06-26 17:44:29.646118	2bebe474-6406-409e-904c-ff7865ac755e	b0d45f2b-2442-48cd-8911-591f4fcf0be7
cf90a144-bb96-4574-b120-0f4367bb0a3f	dislike	2024-06-26 17:44:29.647115	2bdba617-734f-48a5-844c-c7ca5a68781b	b0d45f2b-2442-48cd-8911-591f4fcf0be7
63342523-e719-4da4-9c99-4b534a03b097	like	2024-06-26 17:44:29.647896	7575e78a-a78b-4900-9fb3-b30c925e5f89	b0d45f2b-2442-48cd-8911-591f4fcf0be7
c1103058-53ec-4ac6-872b-71ce46435f64	dislike	2024-06-26 17:44:29.648624	a96df0df-f4a1-4d82-a655-2f7f94ace896	b0d45f2b-2442-48cd-8911-591f4fcf0be7
d6a973fb-227d-4a6b-b4f4-15832d67357d	dislike	2024-06-26 17:44:29.649338	f3c04916-f30d-4360-b465-c5eb262dce94	b0d45f2b-2442-48cd-8911-591f4fcf0be7
eb19843c-d0f9-4178-a557-cee2fb849503	dislike	2024-06-26 17:44:29.650057	d1dbec9d-ce36-42b3-a467-0b1512f41545	b0d45f2b-2442-48cd-8911-591f4fcf0be7
10404481-a7b1-4a3e-a566-30ed89a6b94f	dislike	2024-06-26 17:44:29.650716	960823cf-d908-4246-8fa0-0ac6118797ca	b0d45f2b-2442-48cd-8911-591f4fcf0be7
aaa65024-935b-4207-bc81-2a74055f2411	dislike	2024-06-26 17:44:29.651311	3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	b0d45f2b-2442-48cd-8911-591f4fcf0be7
cf8d6953-d9ed-4262-a817-c05dced6b86d	dislike	2024-06-26 17:44:29.652028	0efabb18-5aff-4a06-8a56-ea882a231b6e	b0d45f2b-2442-48cd-8911-591f4fcf0be7
ac461cfa-177d-4fa2-8a89-00ada145ccd8	dislike	2024-06-26 17:44:29.652701	b0afe2ef-0b3d-481d-9654-f9e67207757d	b0d45f2b-2442-48cd-8911-591f4fcf0be7
7f7c629a-36d0-4368-9fd4-3a6b7bfcd3cc	like	2024-06-26 17:44:29.654474	6f67e1b3-4b5b-4359-b7ea-583eebbfde21	b0d45f2b-2442-48cd-8911-591f4fcf0be7
a963c437-203f-42a7-a823-f3990bfd654e	like	2024-06-26 17:44:29.65561	31c3d5b3-8c7c-4cef-a037-2eccb1839791	b0d45f2b-2442-48cd-8911-591f4fcf0be7
6fa1c427-4f54-4440-82ba-95c91db1dc92	dislike	2024-06-26 17:44:29.656298	6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	b0d45f2b-2442-48cd-8911-591f4fcf0be7
6528507a-4cab-4e71-b78f-bcd04732eec0	like	2024-06-26 17:44:29.657719	c6ef708c-22a7-4dea-85a9-bfc2f5e63608	b0d45f2b-2442-48cd-8911-591f4fcf0be7
a5088fdf-8c22-4409-8565-06fdfdd39e05	dislike	2024-06-26 17:44:29.658731	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	b0d45f2b-2442-48cd-8911-591f4fcf0be7
461395cf-6d68-4357-8345-56f278ba099e	like	2024-06-26 17:44:45.275596	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	0f81f051-ed2a-4931-87bf-544c4f6fe647
f01ad4c4-88f5-4b79-ac12-04623eff2eea	dislike	2024-06-26 17:44:52.594784	9623ff85-67b1-4f4d-8b48-1544c3cb38ab	e0ecda2a-7159-4e41-bff6-53a6e34060a8
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public."user" ("userId", "userName", "firstName", "lastName", email, password, "avatarUrl", bio, "isVerified", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.user_groups ("userId", "groupId") FROM stdin;
d1ec15b3-32ad-42af-b82b-32e4ccccca84	b239d202-2b9d-44b5-9f94-a596fbcdf608
d1ec15b3-32ad-42af-b82b-32e4ccccca84	76de736c-3969-4979-8f1a-6a4afe6d8d7e
f8c6500d-bbf6-4c88-959c-c67c7e572fc0	b239d202-2b9d-44b5-9f94-a596fbcdf608
a96df0df-f4a1-4d82-a655-2f7f94ace896	76de736c-3969-4979-8f1a-6a4afe6d8d7e
d1dbec9d-ce36-42b3-a467-0b1512f41545	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
f3c04916-f30d-4360-b465-c5eb262dce94	b239d202-2b9d-44b5-9f94-a596fbcdf608
76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	9704c250-2c29-4f49-a5dc-c3fface6a852
960823cf-d908-4246-8fa0-0ac6118797ca	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	21de695d-1881-42e4-a55a-488e7b9803cb
cd3675d5-61d6-4adf-96d8-bb5867342208	3d534968-0a02-4591-a212-9bcea2647345
b0afe2ef-0b3d-481d-9654-f9e67207757d	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
a9b20768-6469-4d39-b0aa-c4ed19ae9897	76de736c-3969-4979-8f1a-6a4afe6d8d7e
04b123c0-c2ed-464f-b848-5637bbd7d89d	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
2bdf8bc5-7def-47aa-94ca-7f298307ab35	b239d202-2b9d-44b5-9f94-a596fbcdf608
fcbe60a2-78a6-4f4c-951f-da6422cb80c3	9704c250-2c29-4f49-a5dc-c3fface6a852
6f67e1b3-4b5b-4359-b7ea-583eebbfde21	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
693dab47-5108-490b-9a10-97ff75796112	21de695d-1881-42e4-a55a-488e7b9803cb
31c3d5b3-8c7c-4cef-a037-2eccb1839791	3d534968-0a02-4591-a212-9bcea2647345
645dce1e-7159-4b1b-86f0-0bc601f77b4a	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	76de736c-3969-4979-8f1a-6a4afe6d8d7e
16eca672-7fea-4e30-a715-4aaac96518ce	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
0f6a77b3-b0c1-420a-943d-2ca4b161991d	9704c250-2c29-4f49-a5dc-c3fface6a852
a82ca232-27f5-4edd-a1d8-4678f55e8c8b	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
64d12d2a-f5a9-4109-b79f-561e15f878b6	21de695d-1881-42e4-a55a-488e7b9803cb
c6ef708c-22a7-4dea-85a9-bfc2f5e63608	3d534968-0a02-4591-a212-9bcea2647345
f2d14b9e-18a1-4479-a5da-835c7443586f	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
6a766343-b2eb-491f-8abb-ac90dd69fa95	76de736c-3969-4979-8f1a-6a4afe6d8d7e
d9500d74-9405-4bb6-89b9-6b19147f2cc8	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
220672be-7563-4b84-83f0-cbd497765462	b239d202-2b9d-44b5-9f94-a596fbcdf608
9623ff85-67b1-4f4d-8b48-1544c3cb38ab	9704c250-2c29-4f49-a5dc-c3fface6a852
7575e78a-a78b-4900-9fb3-b30c925e5f89	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
c02fcc25-b9f3-4473-bf1a-80abbdc73474	21de695d-1881-42e4-a55a-488e7b9803cb
2bdba617-734f-48a5-844c-c7ca5a68781b	3d534968-0a02-4591-a212-9bcea2647345
2bebe474-6406-409e-904c-ff7865ac755e	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
b0ed894a-610d-498c-b11f-ed47d2a87b29	76de736c-3969-4979-8f1a-6a4afe6d8d7e
f927fc08-8f8a-4a0b-adec-d924091dcad1	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
4ac4c910-d783-48d5-ae41-b542e8cb666f	b239d202-2b9d-44b5-9f94-a596fbcdf608
7472ab8a-901e-4dac-a330-9bbe4eda5a5a	9704c250-2c29-4f49-a5dc-c3fface6a852
7d2d10ef-c751-4b4c-aff4-8f47c9952491	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	21de695d-1881-42e4-a55a-488e7b9803cb
f8c6500d-bbf6-4c88-959c-c67c7e572fc0	3d534968-0a02-4591-a212-9bcea2647345
5d1b295d-a018-49a2-9c53-a639a3bf51ef	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
745820cf-14e3-4837-be8a-2f7151ec9131	76de736c-3969-4979-8f1a-6a4afe6d8d7e
9e00a085-1e03-4bb5-b18d-65d93f16f743	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
57d296e1-7af7-4cfc-afd2-7bc6352a65e6	b239d202-2b9d-44b5-9f94-a596fbcdf608
d1dbec9d-ce36-42b3-a467-0b1512f41545	9704c250-2c29-4f49-a5dc-c3fface6a852
f3c04916-f30d-4360-b465-c5eb262dce94	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	21de695d-1881-42e4-a55a-488e7b9803cb
960823cf-d908-4246-8fa0-0ac6118797ca	3d534968-0a02-4591-a212-9bcea2647345
3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
cd3675d5-61d6-4adf-96d8-bb5867342208	76de736c-3969-4979-8f1a-6a4afe6d8d7e
b0afe2ef-0b3d-481d-9654-f9e67207757d	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
a9b20768-6469-4d39-b0aa-c4ed19ae9897	b239d202-2b9d-44b5-9f94-a596fbcdf608
04b123c0-c2ed-464f-b848-5637bbd7d89d	9704c250-2c29-4f49-a5dc-c3fface6a852
2bdf8bc5-7def-47aa-94ca-7f298307ab35	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
fcbe60a2-78a6-4f4c-951f-da6422cb80c3	21de695d-1881-42e4-a55a-488e7b9803cb
6f67e1b3-4b5b-4359-b7ea-583eebbfde21	3d534968-0a02-4591-a212-9bcea2647345
693dab47-5108-490b-9a10-97ff75796112	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
31c3d5b3-8c7c-4cef-a037-2eccb1839791	76de736c-3969-4979-8f1a-6a4afe6d8d7e
645dce1e-7159-4b1b-86f0-0bc601f77b4a	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	b239d202-2b9d-44b5-9f94-a596fbcdf608
16eca672-7fea-4e30-a715-4aaac96518ce	9704c250-2c29-4f49-a5dc-c3fface6a852
d1ec15b3-32ad-42af-b82b-32e4ccccca84	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
0f6a77b3-b0c1-420a-943d-2ca4b161991d	21de695d-1881-42e4-a55a-488e7b9803cb
a82ca232-27f5-4edd-a1d8-4678f55e8c8b	3d534968-0a02-4591-a212-9bcea2647345
64d12d2a-f5a9-4109-b79f-561e15f878b6	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
c6ef708c-22a7-4dea-85a9-bfc2f5e63608	76de736c-3969-4979-8f1a-6a4afe6d8d7e
f2d14b9e-18a1-4479-a5da-835c7443586f	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
6a766343-b2eb-491f-8abb-ac90dd69fa95	b239d202-2b9d-44b5-9f94-a596fbcdf608
d9500d74-9405-4bb6-89b9-6b19147f2cc8	9704c250-2c29-4f49-a5dc-c3fface6a852
220672be-7563-4b84-83f0-cbd497765462	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
9623ff85-67b1-4f4d-8b48-1544c3cb38ab	21de695d-1881-42e4-a55a-488e7b9803cb
7575e78a-a78b-4900-9fb3-b30c925e5f89	3d534968-0a02-4591-a212-9bcea2647345
c02fcc25-b9f3-4473-bf1a-80abbdc73474	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
2bdba617-734f-48a5-844c-c7ca5a68781b	76de736c-3969-4979-8f1a-6a4afe6d8d7e
2bebe474-6406-409e-904c-ff7865ac755e	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
b0ed894a-610d-498c-b11f-ed47d2a87b29	b239d202-2b9d-44b5-9f94-a596fbcdf608
f927fc08-8f8a-4a0b-adec-d924091dcad1	9704c250-2c29-4f49-a5dc-c3fface6a852
4ac4c910-d783-48d5-ae41-b542e8cb666f	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
7472ab8a-901e-4dac-a330-9bbe4eda5a5a	21de695d-1881-42e4-a55a-488e7b9803cb
7d2d10ef-c751-4b4c-aff4-8f47c9952491	3d534968-0a02-4591-a212-9bcea2647345
c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
f8c6500d-bbf6-4c88-959c-c67c7e572fc0	76de736c-3969-4979-8f1a-6a4afe6d8d7e
5d1b295d-a018-49a2-9c53-a639a3bf51ef	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
745820cf-14e3-4837-be8a-2f7151ec9131	b239d202-2b9d-44b5-9f94-a596fbcdf608
9e00a085-1e03-4bb5-b18d-65d93f16f743	9704c250-2c29-4f49-a5dc-c3fface6a852
57d296e1-7af7-4cfc-afd2-7bc6352a65e6	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
a96df0df-f4a1-4d82-a655-2f7f94ace896	21de695d-1881-42e4-a55a-488e7b9803cb
d1dbec9d-ce36-42b3-a467-0b1512f41545	3d534968-0a02-4591-a212-9bcea2647345
f3c04916-f30d-4360-b465-c5eb262dce94	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	76de736c-3969-4979-8f1a-6a4afe6d8d7e
3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	b239d202-2b9d-44b5-9f94-a596fbcdf608
cd3675d5-61d6-4adf-96d8-bb5867342208	9704c250-2c29-4f49-a5dc-c3fface6a852
b0afe2ef-0b3d-481d-9654-f9e67207757d	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
a9b20768-6469-4d39-b0aa-c4ed19ae9897	21de695d-1881-42e4-a55a-488e7b9803cb
04b123c0-c2ed-464f-b848-5637bbd7d89d	3d534968-0a02-4591-a212-9bcea2647345
2bdf8bc5-7def-47aa-94ca-7f298307ab35	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
a96df0df-f4a1-4d82-a655-2f7f94ace896	9704c250-2c29-4f49-a5dc-c3fface6a852
d1dbec9d-ce36-42b3-a467-0b1512f41545	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
f3c04916-f30d-4360-b465-c5eb262dce94	21de695d-1881-42e4-a55a-488e7b9803cb
76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	3d534968-0a02-4591-a212-9bcea2647345
960823cf-d908-4246-8fa0-0ac6118797ca	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	76de736c-3969-4979-8f1a-6a4afe6d8d7e
cd3675d5-61d6-4adf-96d8-bb5867342208	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
b0afe2ef-0b3d-481d-9654-f9e67207757d	b239d202-2b9d-44b5-9f94-a596fbcdf608
a9b20768-6469-4d39-b0aa-c4ed19ae9897	9704c250-2c29-4f49-a5dc-c3fface6a852
04b123c0-c2ed-464f-b848-5637bbd7d89d	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
2bdf8bc5-7def-47aa-94ca-7f298307ab35	21de695d-1881-42e4-a55a-488e7b9803cb
fcbe60a2-78a6-4f4c-951f-da6422cb80c3	3d534968-0a02-4591-a212-9bcea2647345
6f67e1b3-4b5b-4359-b7ea-583eebbfde21	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
693dab47-5108-490b-9a10-97ff75796112	76de736c-3969-4979-8f1a-6a4afe6d8d7e
645dce1e-7159-4b1b-86f0-0bc601f77b4a	b239d202-2b9d-44b5-9f94-a596fbcdf608
6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	9704c250-2c29-4f49-a5dc-c3fface6a852
16eca672-7fea-4e30-a715-4aaac96518ce	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
d1ec15b3-32ad-42af-b82b-32e4ccccca84	21de695d-1881-42e4-a55a-488e7b9803cb
0f6a77b3-b0c1-420a-943d-2ca4b161991d	3d534968-0a02-4591-a212-9bcea2647345
a82ca232-27f5-4edd-a1d8-4678f55e8c8b	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
64d12d2a-f5a9-4109-b79f-561e15f878b6	76de736c-3969-4979-8f1a-6a4afe6d8d7e
c6ef708c-22a7-4dea-85a9-bfc2f5e63608	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
f2d14b9e-18a1-4479-a5da-835c7443586f	b239d202-2b9d-44b5-9f94-a596fbcdf608
6a766343-b2eb-491f-8abb-ac90dd69fa95	9704c250-2c29-4f49-a5dc-c3fface6a852
d9500d74-9405-4bb6-89b9-6b19147f2cc8	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
220672be-7563-4b84-83f0-cbd497765462	21de695d-1881-42e4-a55a-488e7b9803cb
9623ff85-67b1-4f4d-8b48-1544c3cb38ab	3d534968-0a02-4591-a212-9bcea2647345
7575e78a-a78b-4900-9fb3-b30c925e5f89	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
c02fcc25-b9f3-4473-bf1a-80abbdc73474	76de736c-3969-4979-8f1a-6a4afe6d8d7e
2bdba617-734f-48a5-844c-c7ca5a68781b	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
2bebe474-6406-409e-904c-ff7865ac755e	b239d202-2b9d-44b5-9f94-a596fbcdf608
b0ed894a-610d-498c-b11f-ed47d2a87b29	9704c250-2c29-4f49-a5dc-c3fface6a852
f927fc08-8f8a-4a0b-adec-d924091dcad1	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
4ac4c910-d783-48d5-ae41-b542e8cb666f	21de695d-1881-42e4-a55a-488e7b9803cb
7472ab8a-901e-4dac-a330-9bbe4eda5a5a	3d534968-0a02-4591-a212-9bcea2647345
7d2d10ef-c751-4b4c-aff4-8f47c9952491	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	76de736c-3969-4979-8f1a-6a4afe6d8d7e
f8c6500d-bbf6-4c88-959c-c67c7e572fc0	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
5d1b295d-a018-49a2-9c53-a639a3bf51ef	b239d202-2b9d-44b5-9f94-a596fbcdf608
745820cf-14e3-4837-be8a-2f7151ec9131	9704c250-2c29-4f49-a5dc-c3fface6a852
9e00a085-1e03-4bb5-b18d-65d93f16f743	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
57d296e1-7af7-4cfc-afd2-7bc6352a65e6	21de695d-1881-42e4-a55a-488e7b9803cb
a96df0df-f4a1-4d82-a655-2f7f94ace896	3d534968-0a02-4591-a212-9bcea2647345
d1dbec9d-ce36-42b3-a467-0b1512f41545	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
f3c04916-f30d-4360-b465-c5eb262dce94	76de736c-3969-4979-8f1a-6a4afe6d8d7e
76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	72ccf4fa-a557-4a29-ad3b-a2bc1c822253
960823cf-d908-4246-8fa0-0ac6118797ca	b239d202-2b9d-44b5-9f94-a596fbcdf608
3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	9704c250-2c29-4f49-a5dc-c3fface6a852
cd3675d5-61d6-4adf-96d8-bb5867342208	f5bf0ba1-59b3-4ebf-8bf0-659482d81487
b0afe2ef-0b3d-481d-9654-f9e67207757d	21de695d-1881-42e4-a55a-488e7b9803cb
a9b20768-6469-4d39-b0aa-c4ed19ae9897	3d534968-0a02-4591-a212-9bcea2647345
04b123c0-c2ed-464f-b848-5637bbd7d89d	a1ca570a-9fa9-499a-8976-d5a1623d5cd8
f927fc08-8f8a-4a0b-adec-d924091dcad1	76de736c-3969-4979-8f1a-6a4afe6d8d7e
9623ff85-67b1-4f4d-8b48-1544c3cb38ab	b239d202-2b9d-44b5-9f94-a596fbcdf608
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: psql
--

COPY public.users ("userId", "userName", "firstName", "lastName", email, password, "avatarUrl", bio, "isVerified", "createdAt", "updatedAt") FROM stdin;
a96df0df-f4a1-4d82-a655-2f7f94ace896	User1@75	John	Doe	john.doe@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/1.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
d1dbec9d-ce36-42b3-a467-0b1512f41545	User2@75	Jane	Smith	jane.smith@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/2.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
f3c04916-f30d-4360-b465-c5eb262dce94	User3@75	Alice	Johnson	alice.johnson@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/3.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
76da11f5-10d2-4e79-af6d-1b92c4f2a0c0	User4@75	Bob	Brown	bob.brown@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/4.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
960823cf-d908-4246-8fa0-0ac6118797ca	User5@75	Charlie	Davis	charlie.davis@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/5.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
3c7ad0b2-0f68-4e9d-b2a7-1219fee50785	User6@75	David	Miller	david.miller@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/6.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
cd3675d5-61d6-4adf-96d8-bb5867342208	User7@75	Eve	Wilson	eve.wilson@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/7.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
b0afe2ef-0b3d-481d-9654-f9e67207757d	User8@75	Frank	Taylor	frank.taylor@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/8.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
a9b20768-6469-4d39-b0aa-c4ed19ae9897	User9@75	Grace	Anderson	grace.anderson@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/9.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
04b123c0-c2ed-464f-b848-5637bbd7d89d	User10@75	Henry	Thomas	henry.thomas@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/10.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
2bdf8bc5-7def-47aa-94ca-7f298307ab35	User11@75	Ivy	Martinez	ivy.martinez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/11.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
6f67e1b3-4b5b-4359-b7ea-583eebbfde21	User14@75	Leo	Gonzalez	leo.gonzalez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/14.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
693dab47-5108-490b-9a10-97ff75796112	User15@75	Mia	Wilson	mia.wilson@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/15.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
31c3d5b3-8c7c-4cef-a037-2eccb1839791	User16@75	Noah	Moore	noah.moore@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/16.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
645dce1e-7159-4b1b-86f0-0bc601f77b4a	User17@75	Olivia	Jackson	olivia.jackson@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/17.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
6a432d6d-6f5f-4d42-a364-efa8a1a9d1e1	User18@75	Paul	Lee	paul.lee@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/18.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
16eca672-7fea-4e30-a715-4aaac96518ce	User19@75	Quinn	Perez	quinn.perez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/19.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
d1ec15b3-32ad-42af-b82b-32e4ccccca84	User20@75	Rachel	Hall	rachel.hall@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/20.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
0f6a77b3-b0c1-420a-943d-2ca4b161991d	User21@75	Steve	Young	steve.young@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/21.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
a82ca232-27f5-4edd-a1d8-4678f55e8c8b	User22@75	Tom	King	tom.king@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/22.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
64d12d2a-f5a9-4109-b79f-561e15f878b6	User23@75	Uma	Wright	uma.wright@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/23.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
c6ef708c-22a7-4dea-85a9-bfc2f5e63608	User24@75	Vera	Scott	vera.scott@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/24.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
f2d14b9e-18a1-4479-a5da-835c7443586f	User25@75	Will	Torres	will.torres@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/25.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
6a766343-b2eb-491f-8abb-ac90dd69fa95	User26@75	Xena	Evans	xena.evans@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/26.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
d9500d74-9405-4bb6-89b9-6b19147f2cc8	User27@75	Yara	Sanders	yara.sanders@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/27.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
220672be-7563-4b84-83f0-cbd497765462	User28@75	Zack	Morris	zack.morris@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/28.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
9623ff85-67b1-4f4d-8b48-1544c3cb38ab	User29@75	Amy	Reed	amy.reed@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/29.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
7575e78a-a78b-4900-9fb3-b30c925e5f89	User30@75	Brian	Cook	brian.cook@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/30.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
c02fcc25-b9f3-4473-bf1a-80abbdc73474	User31@75	Chloe	Morgan	chloe.morgan@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/31.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
2bdba617-734f-48a5-844c-c7ca5a68781b	User32@75	Dylan	Cox	dylan.cox@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/32.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
2bebe474-6406-409e-904c-ff7865ac755e	User33@75	Ella	Bailey	ella.bailey@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/33.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
b0ed894a-610d-498c-b11f-ed47d2a87b29	User34@75	Frank	Rivera	frank.rivera@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/34.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
f927fc08-8f8a-4a0b-adec-d924091dcad1	User35@75	Grace	Peterson	grace.peterson@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/35.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
4ac4c910-d783-48d5-ae41-b542e8cb666f	User36@75	Henry	Gray	henry.gray@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/36.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
7472ab8a-901e-4dac-a330-9bbe4eda5a5a	User37@75	Ivy	Ramirez	ivy.ramirez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/37.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
7d2d10ef-c751-4b4c-aff4-8f47c9952491	User38@75	Jack	Martinez	jack.martinez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/38.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
c0cc7f72-bfb8-497c-8f42-3954aeb91b1c	User39@75	Karen	Rodriguez	karen.rodriguez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/39.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
f8c6500d-bbf6-4c88-959c-c67c7e572fc0	User40@75	Leo	Martinez	leo.martinez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/40.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
5d1b295d-a018-49a2-9c53-a639a3bf51ef	User41@75	Mia	White	mia.white@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/41.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
745820cf-14e3-4837-be8a-2f7151ec9131	User42@75	Noah	Harris	noah.harris@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/42.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
9e00a085-1e03-4bb5-b18d-65d93f16f743	User43@75	Olivia	Clark	olivia.clark@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/women/43.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
57d296e1-7af7-4cfc-afd2-7bc6352a65e6	User44@75	Paul	Lewis	paul.lewis@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	randomuser.me/api/portraits/men/44.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
fcbe60a2-78a6-4f4c-951f-da6422cb80c3	User13@75	Karen	Lopez	karen.lopez@example.com	$2b$10$Y/dI5l3w5BIi63yXQ61KmO6c0ia8a1AsysKpr.JKXvwRR9wKfIiMq	localhost:3000/uploads/avatars/54697a9c-fb79-4979-97a6-0c7c580bfa8f.jpg		f	2024-06-21 18:21:05.522355	2024-06-21 18:21:05.522355
0efabb18-5aff-4a06-8a56-ea882a231b6e	MM	Mazene	zerguine	mazene@email.fr	$2b$10$k3PxRxdbtEHo1y8vdaUxgeSlta1TGiN2p0wUxPcIhgXOYCOcYUH96	localhost:3000/uploads/avatars/f19d5a4b-a6e8-4466-ac5b-5f5bfc448008.jpg	\N	f	2024-06-23 22:33:37.14495	2024-06-23 22:33:37.14495
\.


--
-- Name: comment PK_1b03586f7af11eac99f4fdbf012; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT "PK_1b03586f7af11eac99f4fdbf012" PRIMARY KEY ("commentId");


--
-- Name: program-version PK_365be11da1c3512181c6e703b5c; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."program-version"
    ADD CONSTRAINT "PK_365be11da1c3512181c6e703b5c" PRIMARY KEY ("programVersionId");


--
-- Name: program PK_4402716c9ca2c8e92092d118944; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT "PK_4402716c9ca2c8e92092d118944" PRIMARY KEY ("programId");


--
-- Name: group_programs PK_51bb98d9644d9fe4e1d5ae34b53; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.group_programs
    ADD CONSTRAINT "PK_51bb98d9644d9fe4e1d5ae34b53" PRIMARY KEY ("groupId", "programId");


--
-- Name: group PK_52a5b0126abd6ad70828290e822; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT "PK_52a5b0126abd6ad70828290e822" PRIMARY KEY ("groupId");


--
-- Name: follow PK_820ef916b8c67edfad7ea90ba0f; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.follow
    ADD CONSTRAINT "PK_820ef916b8c67edfad7ea90ba0f" PRIMARY KEY ("relationId");


--
-- Name: reaction_entity PK_8afbbf659964bfe9f28a321de1e; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.reaction_entity
    ADD CONSTRAINT "PK_8afbbf659964bfe9f28a321de1e" PRIMARY KEY ("reactionId");


--
-- Name: users PK_8bf09ba754322ab9c22a215c919; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_8bf09ba754322ab9c22a215c919" PRIMARY KEY ("userId");


--
-- Name: program-versions PK_9e528c92c85a150c8835606bfde; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."program-versions"
    ADD CONSTRAINT "PK_9e528c92c85a150c8835606bfde" PRIMARY KEY ("programVersionId");


--
-- Name: user PK_d72ea127f30e21753c9e229891e; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "PK_d72ea127f30e21753c9e229891e" PRIMARY KEY ("userId");


--
-- Name: user_groups PK_dc24675c437bf3c70d3d0dff67f; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT "PK_dc24675c437bf3c70d3d0dff67f" PRIMARY KEY ("userId", "groupId");


--
-- Name: program_version_entity PK_dd0cf15473d0ee84e318a55ff06; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.program_version_entity
    ADD CONSTRAINT "PK_dd0cf15473d0ee84e318a55ff06" PRIMARY KEY ("programVersionId");


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: reaction_entity UQ_c2727d13e7c3be98dd491cbaebe; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.reaction_entity
    ADD CONSTRAINT "UQ_c2727d13e7c3be98dd491cbaebe" UNIQUE ("programId", "userId");


--
-- Name: user UQ_e12875dfb3b1d92d7d7c5377e22; Type: CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e22" UNIQUE (email);


--
-- Name: IDX_4dcea3f5c6f04650517d9dc475; Type: INDEX; Schema: public; Owner: psql
--

CREATE INDEX "IDX_4dcea3f5c6f04650517d9dc475" ON public.user_groups USING btree ("groupId");


--
-- Name: IDX_8a174f55a4ad2841e61d188505; Type: INDEX; Schema: public; Owner: psql
--

CREATE INDEX "IDX_8a174f55a4ad2841e61d188505" ON public.group_programs USING btree ("groupId");


--
-- Name: IDX_97672ac88f789774dd47f7c8be; Type: INDEX; Schema: public; Owner: psql
--

CREATE INDEX "IDX_97672ac88f789774dd47f7c8be" ON public.users USING btree (email);


--
-- Name: IDX_99d01ff7f143377c044f3d6c95; Type: INDEX; Schema: public; Owner: psql
--

CREATE INDEX "IDX_99d01ff7f143377c044f3d6c95" ON public.user_groups USING btree ("userId");


--
-- Name: IDX_c6e7a84f75fe64cc348a54156f; Type: INDEX; Schema: public; Owner: psql
--

CREATE INDEX "IDX_c6e7a84f75fe64cc348a54156f" ON public.group_programs USING btree ("programId");


--
-- Name: IDX_e12875dfb3b1d92d7d7c5377e2; Type: INDEX; Schema: public; Owner: psql
--

CREATE INDEX "IDX_e12875dfb3b1d92d7d7c5377e2" ON public."user" USING btree (email);


--
-- Name: user_groups FK_4dcea3f5c6f04650517d9dc4750; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT "FK_4dcea3f5c6f04650517d9dc4750" FOREIGN KEY ("groupId") REFERENCES public."group"("groupId");


--
-- Name: follow FK_673eb90803096b4300d2f547a4c; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.follow
    ADD CONSTRAINT "FK_673eb90803096b4300d2f547a4c" FOREIGN KEY ("followerUserId") REFERENCES public.users("userId");


--
-- Name: program-versions FK_73936ebfe47aae85cede55334e7; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."program-versions"
    ADD CONSTRAINT "FK_73936ebfe47aae85cede55334e7" FOREIGN KEY ("programProgramId") REFERENCES public.program("programId");


--
-- Name: comment FK_73aac6035a70c5f0313c939f237; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT "FK_73aac6035a70c5f0313c939f237" FOREIGN KEY ("parentCommentId") REFERENCES public.comment("commentId") ON DELETE CASCADE;


--
-- Name: group_programs FK_8a174f55a4ad2841e61d1885050; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.group_programs
    ADD CONSTRAINT "FK_8a174f55a4ad2841e61d1885050" FOREIGN KEY ("groupId") REFERENCES public."group"("groupId") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_groups FK_99d01ff7f143377c044f3d6c955; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT "FK_99d01ff7f143377c044f3d6c955" FOREIGN KEY ("userId") REFERENCES public.users("userId") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: follow FK_a46b5b444603dfa4e356d8721b6; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.follow
    ADD CONSTRAINT "FK_a46b5b444603dfa4e356d8721b6" FOREIGN KEY ("followingUserId") REFERENCES public.users("userId");


--
-- Name: comment FK_b4470bd83e8cf8a697761c9c974; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT "FK_b4470bd83e8cf8a697761c9c974" FOREIGN KEY ("programId") REFERENCES public.program("programId") ON DELETE CASCADE;


--
-- Name: program FK_bb38d80121a98937581cdd39f1b; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT "FK_bb38d80121a98937581cdd39f1b" FOREIGN KEY ("userUserId") REFERENCES public.users("userId");


--
-- Name: program-version FK_bd6a2bb7f5f823543f29debc9b6; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."program-version"
    ADD CONSTRAINT "FK_bd6a2bb7f5f823543f29debc9b6" FOREIGN KEY ("programProgramId") REFERENCES public.program("programId") ON DELETE CASCADE;


--
-- Name: comment FK_c0354a9a009d3bb45a08655ce3b; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT "FK_c0354a9a009d3bb45a08655ce3b" FOREIGN KEY ("userId") REFERENCES public.users("userId");


--
-- Name: group_programs FK_c6e7a84f75fe64cc348a54156fe; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.group_programs
    ADD CONSTRAINT "FK_c6e7a84f75fe64cc348a54156fe" FOREIGN KEY ("programId") REFERENCES public.program("programId") ON DELETE CASCADE;


--
-- Name: group FK_d842262ed825467f5eefaa33c7a; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT "FK_d842262ed825467f5eefaa33c7a" FOREIGN KEY ("ownerUserId") REFERENCES public.users("userId");


--
-- Name: program_version_entity FK_e79400ba7dad5c8110e1d1fbbd8; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.program_version_entity
    ADD CONSTRAINT "FK_e79400ba7dad5c8110e1d1fbbd8" FOREIGN KEY ("programProgramId") REFERENCES public.program("programId");


--
-- Name: reaction_entity FK_e97b6649b2914160e8f502f8858; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.reaction_entity
    ADD CONSTRAINT "FK_e97b6649b2914160e8f502f8858" FOREIGN KEY ("programId") REFERENCES public.program("programId") ON DELETE CASCADE;


--
-- Name: reaction_entity FK_ec42c5a5dfd35f948b93cdf04f7; Type: FK CONSTRAINT; Schema: public; Owner: psql
--

ALTER TABLE ONLY public.reaction_entity
    ADD CONSTRAINT "FK_ec42c5a5dfd35f948b93cdf04f7" FOREIGN KEY ("userId") REFERENCES public.users("userId");


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: psql
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

