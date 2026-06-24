import {
  pgTable,
  serial,
  text,
  timestamp,
  boolean,
  integer,
  pgEnum,
  decimal,
} from "drizzle-orm/pg-core";

// ─── Enums ───────────────────────────────────────────────────────────────────

export const teamCategoryEnum = pgEnum("team_category", [
  "aktive",
  "frauen",
  "senioren",
  "junioren",
]);

export const sponsorCategoryEnum = pgEnum("sponsor_category", [
  "hauptsponsor",
  "co_sponsor",
  "junioren_patron",
  "top_club_88",
]);

export const personCategoryEnum = pgEnum("person_category", [
  "vorstand",
  "trainer",
  "ansprechperson",
]);

// ─── News ────────────────────────────────────────────────────────────────────

export const news = pgTable("news", {
  id: serial("id").primaryKey(),
  slug: text("slug").notNull().unique(),
  title: text("title").notNull(),
  content: text("content").notNull(),
  imageUrl: text("image_url"),
  published: boolean("published").default(true),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

// ─── Teams ───────────────────────────────────────────────────────────────────

export const teams = pgTable("teams", {
  id: serial("id").primaryKey(),
  slug: text("slug").notNull().unique(),
  name: text("name").notNull(),
  category: teamCategoryEnum("category").notNull(),
  liga: text("liga"),
  description: text("description"),
  imageUrl: text("image_url"),
  trainerName: text("trainer_name"),
  trainerContact: text("trainer_contact"),
  matchcenterUrl: text("matchcenter_url"),
  sortOrder: integer("sort_order").default(0),
});

// ─── People (Vorstand, Trainer, Ansprechpersonen) ────────────────────────────

export const people = pgTable("people", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  role: text("role").notNull(),
  category: personCategoryEnum("category").notNull(),
  email: text("email"),
  phone: text("phone"),
  imageUrl: text("image_url"),
  sortOrder: integer("sort_order").default(0),
});

// ─── Sponsors ────────────────────────────────────────────────────────────────

export const sponsors = pgTable("sponsors", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  category: sponsorCategoryEnum("category").notNull(),
  logoUrl: text("logo_url"),
  website: text("website"),
  sortOrder: integer("sort_order").default(0),
});

// ─── Shop ────────────────────────────────────────────────────────────────────

export const shopProducts = pgTable("shop_products", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  description: text("description"),
  imageUrl: text("image_url"),
  price: decimal("price", { precision: 10, scale: 2 }),
  available: boolean("available").default(true),
  sortOrder: integer("sort_order").default(0),
});

// ─── Events ──────────────────────────────────────────────────────────────────

export const events = pgTable("events", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description"),
  eventDate: timestamp("event_date").notNull(),
  location: text("location"),
  imageUrl: text("image_url"),
  published: boolean("published").default(true),
});

// ─── Helferportal ────────────────────────────────────────────────────────────

export const helperShifts = pgTable("helper_shifts", {
  id: serial("id").primaryKey(),
  eventTitle: text("event_title").notNull(),
  date: timestamp("date").notNull(),
  role: text("role").notNull(),
  slotsTotal: integer("slots_total").notNull(),
  slotsTaken: integer("slots_taken").default(0),
  notes: text("notes"),
});

export const helperSignups = pgTable("helper_signups", {
  id: serial("id").primaryKey(),
  shiftId: integer("shift_id")
    .notNull()
    .references(() => helperShifts.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  email: text("email").notNull(),
  createdAt: timestamp("created_at").defaultNow(),
});

// ─── Vorfall-Meldungen ───────────────────────────────────────────────────────

export const incidentReports = pgTable("incident_reports", {
  id: serial("id").primaryKey(),
  name: text("name"),
  email: text("email"),
  message: text("message").notNull(),
  status: text("status").default("neu"),
  createdAt: timestamp("created_at").defaultNow(),
});

// ─── Statische Seiten-Inhalte (key-value) ────────────────────────────────────

export const siteContent = pgTable("site_content", {
  key: text("key").primaryKey(),
  value: text("value").notNull(),
  updatedAt: timestamp("updated_at").defaultNow(),
});
