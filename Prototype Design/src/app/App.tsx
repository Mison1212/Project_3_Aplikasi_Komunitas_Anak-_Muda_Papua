import { useState } from "react";
import {
  LayoutDashboard,
  Briefcase,
  FileText,
  Users,
  Shield,
  Search,
  MapPin,
  Building2,
  Clock,
  ChevronRight,
  ArrowLeft,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Phone,
  Mail,
  Plus,
  Trash2,
  TrendingUp,
  BarChart3,
  Edit2,
  X,
  Save,
  Tag,
  Eye,
  RefreshCw,
  LogOut,
  Bell,
  Filter,
  ChevronDown,
  Check,
  Map,
} from "lucide-react";

// ─── DATA ────────────────────────────────────────────────────────────────────

type AdminScreen =
  | "login"
  | "dashboard"
  | "users"
  | "jobs"
  | "job-form"
  | "applications"
  | "kabupaten"
  | "karir-master";

const KABUPATEN_LIST = [
  "Jayapura", "Sorong", "Timika", "Manokwari", "Wamena",
  "Merauke", "Nabire", "Biak", "Fakfak", "Kaimana",
  "Tolikara", "Pegunungan Bintang",
];

const KARIR_LIST = [
  "Teknologi Informasi", "Kesehatan", "Pendidikan", "Pertanian",
  "Pertambangan", "Perikanan", "Administrasi", "Hukum", "Pariwisata",
];

const INIT_JOBS = [
  { id: 1, title: "Frontend Developer", company: "PT. Papua Digital Nusantara", location: "Jayapura", category: "Teknologi Informasi", deadline: "2025-08-15", salary: "Rp 5.000.000 – Rp 8.000.000", description: "Mencari Frontend Developer berpengalaman React.js untuk membangun antarmuka responsif dan modern." },
  { id: 2, title: "Tenaga Kesehatan Masyarakat", company: "Dinas Kesehatan Provinsi Papua", location: "Sorong", category: "Kesehatan", deadline: "2025-07-30", salary: "Rp 4.000.000 – Rp 6.000.000", description: "Dibutuhkan tenaga kesehatan untuk program pemberdayaan di wilayah pedalaman Papua." },
  { id: 3, title: "Guru SD Perbatasan", company: "Kemendikbud – Papua Pegunungan", location: "Wamena", category: "Pendidikan", deadline: "2025-08-01", salary: "Rp 3.500.000 – Rp 5.500.000", description: "Rekrutmen guru SD daerah perbatasan Papua dalam program Guru Terdepan." },
  { id: 4, title: "Staf Administrasi", company: "PT. Freeport Indonesia", location: "Timika", category: "Administrasi", deadline: "2025-07-25", salary: "Rp 4.500.000 – Rp 7.000.000", description: "Staf administrasi untuk mengelola dokumen, surat-menyurat, dan pelaporan internal." },
];

const INIT_USERS = [
  { id: 1, name: "Yohanes Wenda", kabupaten: "Wamena", karir: "Teknologi Informasi", email: "yohanes@email.com", phone: "081234567890", regDate: "2025-06-01" },
  { id: 2, name: "Maria Kogoya", kabupaten: "Jayapura", karir: "Kesehatan", email: "maria@email.com", phone: "082345678901", regDate: "2025-06-05" },
  { id: 3, name: "Petrus Mote", kabupaten: "Sorong", karir: "Pendidikan", email: "petrus@email.com", phone: "083456789012", regDate: "2025-06-10" },
  { id: 4, name: "Lucia Enumbi", kabupaten: "Nabire", karir: "Pertanian", email: "lucia@email.com", phone: "084567890123", regDate: "2025-06-12" },
  { id: 5, name: "Daniel Ayomi", kabupaten: "Merauke", karir: "Administrasi", email: "daniel@email.com", phone: "085678901234", regDate: "2025-06-18" },
];

const INIT_LAMARAN = [
  { id: 1, userId: 1, userName: "Yohanes Wenda", jobId: 1, jobTitle: "Frontend Developer", company: "PT. Papua Digital Nusantara", status: "pending", date: "2025-07-01" },
  { id: 2, userId: 2, userName: "Maria Kogoya", jobId: 2, jobTitle: "Tenaga Kesehatan Masyarakat", company: "Dinas Kesehatan Provinsi Papua", status: "accepted", date: "2025-06-20" },
  { id: 3, userId: 3, userName: "Petrus Mote", jobId: 3, jobTitle: "Guru SD Perbatasan", company: "Kemendikbud – Papua Pegunungan", status: "rejected", date: "2025-06-15" },
  { id: 4, userId: 4, userName: "Lucia Enumbi", jobId: 1, jobTitle: "Frontend Developer", company: "PT. Papua Digital Nusantara", status: "pending", date: "2025-07-02" },
  { id: 5, userId: 5, userName: "Daniel Ayomi", jobId: 4, jobTitle: "Staf Administrasi", company: "PT. Freeport Indonesia", status: "accepted", date: "2025-06-28" },
];

// ─── HELPERS ──────────────────────────────────────────────────────────────────

const statusBadge = (status: string) => {
  if (status === "accepted") return { label: "Diterima", bg: "bg-emerald-100 text-emerald-700 border-emerald-200", dot: "bg-emerald-500" };
  if (status === "rejected") return { label: "Ditolak", bg: "bg-red-100 text-red-600 border-red-200", dot: "bg-red-500" };
  return { label: "Menunggu", bg: "bg-amber-100 text-amber-700 border-amber-200", dot: "bg-amber-500" };
};

const nextStatus = (s: string) => s === "pending" ? "accepted" : s === "accepted" ? "rejected" : "pending";

// ─── ROOT APP ─────────────────────────────────────────────────────────────────

export default function App() {
  const [screen, setScreen] = useState<AdminScreen>("login");
  const [adminPass, setAdminPass] = useState("");
  const [jobs, setJobs] = useState(INIT_JOBS);
  const [users] = useState(INIT_USERS);
  const [lamaran, setLamaran] = useState(INIT_LAMARAN);
  const [editingJob, setEditingJob] = useState<typeof INIT_JOBS[0] | null>(null);
  const [notif, setNotif] = useState<string | null>(null);
  const [prevScreen, setPrevScreen] = useState<AdminScreen>("dashboard");

  const toast = (msg: string) => { setNotif(msg); setTimeout(() => setNotif(null), 2500); };

  const go = (s: AdminScreen, prev?: AdminScreen) => {
    if (prev) setPrevScreen(prev);
    setScreen(s);
  };

  const handleDeleteJob = (id: number) => {
    setJobs((j) => j.filter((x) => x.id !== id));
    toast("Lowongan berhasil dihapus");
  };

  const handleSaveJob = (job: typeof INIT_JOBS[0]) => {
    if (job.id === 0) {
      setJobs((j) => [...j, { ...job, id: Date.now() }]);
      toast("Lowongan baru berhasil ditambahkan");
    } else {
      setJobs((j) => j.map((x) => x.id === job.id ? job : x));
      toast("Lowongan berhasil diperbarui");
    }
    setScreen("jobs");
  };

  const handleToggleStatus = (id: number) => {
    setLamaran((prev) => prev.map((l) => l.id === id ? { ...l, status: nextStatus(l.status) } : l));
  };

  const mainScreens: AdminScreen[] = ["dashboard", "users", "jobs", "applications", "kabupaten", "karir-master"];
  const isMain = mainScreens.includes(screen);

  const navItems = [
    { label: "Dashboard", icon: LayoutDashboard, screen: "dashboard" as AdminScreen },
    { label: "Lowongan", icon: Briefcase, screen: "jobs" as AdminScreen },
    { label: "Lamaran", icon: FileText, screen: "applications" as AdminScreen },
    { label: "User", icon: Users, screen: "users" as AdminScreen },
    { label: "Master", icon: Map, screen: "kabupaten" as AdminScreen },
  ];

  return (
    <div
      className="min-h-screen flex items-center justify-center p-4"
      style={{
        fontFamily: "'Plus Jakarta Sans', sans-serif",
        background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 50%, #06c2ae 100%)",
      }}
    >
      {/* Phone Frame */}
      <div className="relative w-[390px] h-[844px] bg-[#f0fafa] rounded-[3rem] shadow-2xl shadow-black/40 overflow-hidden flex flex-col border-4 border-white/20">

        {/* Toast */}
        {notif && (
          <div className="absolute top-14 left-1/2 -translate-x-1/2 z-50 bg-gray-900 text-white text-xs px-4 py-2 rounded-full shadow-xl flex items-center gap-2 whitespace-nowrap">
            <Check size={12} className="text-emerald-400" /> {notif}
          </div>
        )}

        {/* Status Bar */}
        <div className="flex-shrink-0 bg-white/80 backdrop-blur-sm px-6 pt-3 pb-1 flex items-center justify-between">
          <span className="text-xs font-semibold text-teal-900">9:41</span>
          <div className="flex gap-1.5 items-center">
            <div className="w-4 h-2 border border-teal-700 rounded-sm relative">
              <div className="absolute inset-0.5 bg-teal-600 rounded-sm w-[70%]" />
            </div>
            <div className="flex gap-0.5 items-end h-3">
              {[1, 2, 3].map((i) => (
                <div key={i} className="w-1 bg-teal-700 rounded-sm" style={{ height: `${i * 30}%` }} />
              ))}
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-hidden flex flex-col">
          {screen === "login" && (
            <AdminLoginScreen pass={adminPass} setPass={setAdminPass} onLogin={() => go("dashboard")} />
          )}
          {screen === "dashboard" && (
            <DashboardScreen
              jobs={jobs} users={users} lamaran={lamaran}
              onNavigate={go}
              onLogout={() => go("login")}
            />
          )}
          {screen === "users" && (
            <UsersScreen users={users} lamaran={lamaran} />
          )}
          {screen === "jobs" && (
            <JobsScreen
              jobs={jobs}
              onAdd={() => { setEditingJob({ id: 0, title: "", company: "", location: "", category: "", deadline: "", salary: "", description: "" }); go("job-form", "jobs"); }}
              onEdit={(job) => { setEditingJob(job); go("job-form", "jobs"); }}
              onDelete={handleDeleteJob}
            />
          )}
          {screen === "job-form" && editingJob && (
            <JobFormScreen
              job={editingJob}
              onBack={() => setScreen("jobs")}
              onSave={handleSaveJob}
            />
          )}
          {screen === "applications" && (
            <ApplicationsScreen lamaran={lamaran} onToggle={handleToggleStatus} />
          )}
          {screen === "kabupaten" && (
            <KabupatenScreen onToast={toast} />
          )}
          {screen === "karir-master" && (
            <KarirScreen onToast={toast} onBack={() => setScreen("kabupaten")} />
          )}
        </div>

        {/* Bottom Nav */}
        {isMain && (
          <div className="flex-shrink-0 bg-white border-t border-teal-100 px-1 py-2 flex items-center justify-around shadow-lg">
            {navItems.map((item) => {
              const active = screen === item.screen || (screen === "job-form" && item.screen === "jobs") || (screen === "karir-master" && item.screen === "kabupaten");
              return (
                <button
                  key={item.screen}
                  onClick={() => go(item.screen)}
                  className={`flex flex-col items-center gap-0.5 px-2.5 py-1 rounded-xl transition-all ${active ? "text-teal-600" : "text-gray-400"}`}
                >
                  <div className={`p-1.5 rounded-xl transition-all ${active ? "bg-teal-50" : ""}`}>
                    <item.icon size={19} strokeWidth={active ? 2.5 : 1.8} />
                  </div>
                  <span className="text-[10px] font-semibold">{item.label}</span>
                </button>
              );
            })}
          </div>
        )}
      </div>

      <div className="absolute bottom-6 left-1/2 -translate-x-1/2 text-white/50 text-xs font-medium tracking-widest uppercase">
        Karir Muda Papua — Admin v2
      </div>
    </div>
  );
}

// ─── ADMIN LOGIN ──────────────────────────────────────────────────────────────

function AdminLoginScreen({ pass, setPass, onLogin }: any) {
  const [show, setShow] = useState(false);
  return (
    <div className="flex-1 overflow-y-auto">
      <div
        className="px-6 pt-10 pb-14 text-white"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <div className="w-14 h-14 bg-white/20 rounded-2xl flex items-center justify-center mb-4 backdrop-blur-sm">
          <Shield size={28} className="text-white" />
        </div>
        <h1 className="text-2xl font-bold" style={{ fontFamily: "'Outfit', sans-serif" }}>Admin Panel</h1>
        <p className="text-teal-200 text-sm mt-1">Karir Muda Papua — Sistem Pengelolaan</p>
      </div>

      <div className="px-6 -mt-6">
        <div className="bg-white rounded-3xl shadow-xl shadow-teal-100/60 p-6">
          <div className="flex items-center gap-3 mb-6 p-3 bg-amber-50 rounded-xl border border-amber-100">
            <AlertCircle size={16} className="text-amber-500 flex-shrink-0" />
            <p className="text-xs text-amber-700">Akses terbatas untuk administrator sistem.</p>
          </div>

          <div className="space-y-4">
            <div>
              <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1.5">Email Admin</label>
              <div className="flex items-center bg-teal-50 rounded-xl px-4 border border-teal-100">
                <Mail size={15} className="text-teal-400 mr-2 flex-shrink-0" />
                <input
                  type="email"
                  defaultValue="admin@karirmudapapua.id"
                  className="flex-1 bg-transparent py-3 text-sm text-gray-700 outline-none"
                />
              </div>
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1.5">Kata Sandi</label>
              <div className="flex items-center bg-teal-50 rounded-xl px-4 border border-teal-100">
                <input
                  type={show ? "text" : "password"}
                  value={pass}
                  onChange={(e) => setPass(e.target.value)}
                  placeholder="••••••••"
                  className="flex-1 bg-transparent py-3 text-sm text-gray-700 outline-none placeholder-gray-300"
                />
                <button onClick={() => setShow(!show)} className="text-teal-400">
                  <Eye size={15} />
                </button>
              </div>
            </div>

            <button
              onClick={onLogin}
              className="w-full py-3.5 rounded-xl font-semibold text-sm text-white shadow-lg shadow-teal-200 transition-all active:scale-[0.98]"
              style={{ background: "linear-gradient(135deg, #0b9e8e, #06c2ae)" }}
            >
              Masuk sebagai Admin
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── DASHBOARD ────────────────────────────────────────────────────────────────

function DashboardScreen({ jobs, users, lamaran, onNavigate, onLogout }: any) {
  const pending = lamaran.filter((l: any) => l.status === "pending").length;
  const accepted = lamaran.filter((l: any) => l.status === "accepted").length;
  const rejected = lamaran.filter((l: any) => l.status === "rejected").length;

  const stats = [
    { label: "Total User", value: users.length, icon: Users, color: "#0b9e8e", bg: "#e0f5f3" },
    { label: "Lowongan", value: jobs.length, icon: Briefcase, color: "#0284c7", bg: "#e0f2fe" },
    { label: "Lamaran", value: lamaran.length, icon: FileText, color: "#7c3aed", bg: "#ede9fe" },
    { label: "Diterima", value: accepted, icon: CheckCircle2, color: "#059669", bg: "#d1fae5" },
  ];

  const recentApps = lamaran.slice(-3).reverse();

  return (
    <div className="flex-1 overflow-y-auto">
      {/* Header */}
      <div
        className="px-5 pt-5 pb-6 text-white"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <div className="flex items-center justify-between mb-1">
          <div>
            <p className="text-teal-300 text-xs">Selamat datang,</p>
            <h2 className="text-lg font-bold" style={{ fontFamily: "'Outfit', sans-serif" }}>Administrator</h2>
          </div>
          <div className="flex items-center gap-2">
            {pending > 0 && (
              <div className="relative">
                <Bell size={20} className="text-white/70" />
                <span className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full text-[9px] flex items-center justify-center font-bold">{pending}</span>
              </div>
            )}
            <button onClick={onLogout} className="w-8 h-8 bg-white/15 rounded-xl flex items-center justify-center">
              <LogOut size={15} />
            </button>
          </div>
        </div>
        <p className="text-teal-300 text-xs">{pending} lamaran menunggu persetujuan</p>
      </div>

      <div className="px-4 py-4">
        {/* Stats */}
        <div className="grid grid-cols-2 gap-2.5 mb-4">
          {stats.map((s) => (
            <div key={s.label} className="bg-white rounded-2xl p-3.5 shadow-sm border border-teal-50 flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: s.bg }}>
                <s.icon size={18} style={{ color: s.color }} />
              </div>
              <div>
                <div className="text-xl font-bold text-gray-800" style={{ fontFamily: "'Outfit', sans-serif" }}>{s.value}</div>
                <div className="text-xs text-gray-400">{s.label}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Lamaran Status Bar */}
        <div className="bg-white rounded-2xl p-4 mb-3 shadow-sm border border-teal-50">
          <h3 className="text-sm font-bold text-gray-700 mb-3" style={{ fontFamily: "'Outfit', sans-serif" }}>Ringkasan Lamaran</h3>
          <div className="flex rounded-xl overflow-hidden h-3 mb-3">
            {lamaran.length > 0 && (
              <>
                <div className="bg-amber-400 transition-all" style={{ width: `${(pending / lamaran.length) * 100}%` }} />
                <div className="bg-emerald-400 transition-all" style={{ width: `${(accepted / lamaran.length) * 100}%` }} />
                <div className="bg-red-400 transition-all" style={{ width: `${(rejected / lamaran.length) * 100}%` }} />
              </>
            )}
          </div>
          <div className="flex gap-3 text-xs">
            {[
              { label: "Menunggu", val: pending, color: "bg-amber-400" },
              { label: "Diterima", val: accepted, color: "bg-emerald-400" },
              { label: "Ditolak", val: rejected, color: "bg-red-400" },
            ].map((item) => (
              <div key={item.label} className="flex items-center gap-1.5">
                <div className={`w-2 h-2 rounded-full ${item.color}`} />
                <span className="text-gray-500">{item.label} <span className="font-bold text-gray-700">{item.val}</span></span>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Nav */}
        <div className="bg-white rounded-2xl p-4 mb-3 shadow-sm border border-teal-50">
          <h3 className="text-sm font-bold text-gray-700 mb-3" style={{ fontFamily: "'Outfit', sans-serif" }}>Kelola Data</h3>
          <div className="space-y-2">
            {[
              { label: "Kelola Lowongan", sub: `${jobs.length} lowongan aktif`, icon: Briefcase, color: "#0284c7", bg: "#e0f2fe", sc: "jobs" as AdminScreen },
              { label: "Data User", sub: `${users.length} pengguna terdaftar`, icon: Users, color: "#7c3aed", bg: "#ede9fe", sc: "users" as AdminScreen },
              { label: "Kelola Lamaran", sub: `${pending} menunggu`, icon: FileText, color: "#0b9e8e", bg: "#e0f5f3", sc: "applications" as AdminScreen },
              { label: "Data Master", sub: "Kabupaten & karir", icon: Map, color: "#d97706", bg: "#fef3c7", sc: "kabupaten" as AdminScreen },
            ].map((item) => (
              <button
                key={item.label}
                onClick={() => onNavigate(item.sc)}
                className="w-full flex items-center gap-3 p-2.5 rounded-xl hover:bg-gray-50 transition-colors"
              >
                <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: item.bg }}>
                  <item.icon size={16} style={{ color: item.color }} />
                </div>
                <div className="flex-1 text-left">
                  <div className="text-sm font-semibold text-gray-700">{item.label}</div>
                  <div className="text-xs text-gray-400">{item.sub}</div>
                </div>
                <ChevronRight size={15} className="text-gray-300" />
              </button>
            ))}
          </div>
        </div>

        {/* Recent Applications */}
        <div className="bg-white rounded-2xl p-4 shadow-sm border border-teal-50 mb-4">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-sm font-bold text-gray-700" style={{ fontFamily: "'Outfit', sans-serif" }}>Lamaran Terbaru</h3>
            <button onClick={() => onNavigate("applications")} className="text-xs text-teal-600 font-semibold">Lihat semua</button>
          </div>
          <div className="space-y-2">
            {recentApps.map((item: any) => {
              const badge = statusBadge(item.status);
              return (
                <div key={item.id} className="flex items-center gap-3 py-1">
                  <div className="w-8 h-8 bg-gradient-to-br from-teal-400 to-cyan-500 rounded-xl flex items-center justify-center text-white font-bold text-xs flex-shrink-0">
                    {item.userName.charAt(0)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-xs font-semibold text-gray-700 truncate">{item.userName}</div>
                    <div className="text-[11px] text-gray-400 truncate">{item.jobTitle}</div>
                  </div>
                  <span className={`text-[10px] px-2 py-0.5 rounded-full font-semibold border ${badge.bg}`}>{badge.label}</span>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── USERS ────────────────────────────────────────────────────────────────────

function UsersScreen({ users, lamaran }: any) {
  const [search, setSearch] = useState("");
  const filtered = users.filter((u: any) =>
    u.name.toLowerCase().includes(search.toLowerCase()) ||
    u.kabupaten.toLowerCase().includes(search.toLowerCase()) ||
    u.karir.toLowerCase().includes(search.toLowerCase())
  );
  return (
    <div className="flex-1 overflow-y-auto">
      <div
        className="px-5 pt-5 pb-5 text-white"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <h2 className="text-xl font-bold mb-3" style={{ fontFamily: "'Outfit', sans-serif" }}>Data User</h2>
        <div className="flex items-center bg-white/20 backdrop-blur-sm rounded-xl px-4 border border-white/20">
          <Search size={15} className="text-white/60 mr-2" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Cari nama, kabupaten, karir..."
            className="flex-1 bg-transparent py-2.5 text-sm text-white outline-none placeholder-white/50"
          />
        </div>
      </div>

      <div className="px-4 py-3">
        <p className="text-xs text-gray-400 font-semibold mb-3">{filtered.length} pengguna ditemukan</p>
        <div className="space-y-2.5">
          {filtered.map((u: typeof INIT_USERS[0]) => {
            const userLamaran = lamaran.filter((l: any) => l.userId === u.id);
            const accepted = userLamaran.filter((l: any) => l.status === "accepted").length;
            return (
              <div key={u.id} className="bg-white rounded-2xl p-4 shadow-sm border border-teal-50">
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-teal-400 to-cyan-500 rounded-xl flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
                    {u.name.charAt(0)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="font-semibold text-sm text-gray-800">{u.name}</div>
                    <div className="flex gap-1.5 mt-1 flex-wrap">
                      <span className="text-[11px] bg-teal-50 text-teal-700 px-2 py-0.5 rounded-full border border-teal-100 flex items-center gap-1">
                        <MapPin size={9} /> {u.kabupaten}
                      </span>
                      <span className="text-[11px] bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full border border-blue-100 flex items-center gap-1">
                        <Tag size={9} /> {u.karir}
                      </span>
                    </div>
                  </div>
                  <div className="text-right text-xs flex-shrink-0">
                    <div className="font-bold text-gray-700">{userLamaran.length}</div>
                    <div className="text-gray-400">lamaran</div>
                  </div>
                </div>
                <div className="border-t border-gray-50 pt-2.5 flex items-center justify-between">
                  <div className="space-y-0.5">
                    <div className="flex items-center gap-1.5 text-xs text-gray-500">
                      <Mail size={11} className="text-gray-300" /> {u.email}
                    </div>
                    <div className="flex items-center gap-1.5 text-xs text-teal-600 font-semibold">
                      <Phone size={11} /> {u.phone}
                    </div>
                  </div>
                  {accepted > 0 && (
                    <span className="text-[11px] bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold border border-emerald-200 flex items-center gap-1">
                      <CheckCircle2 size={10} /> {accepted} diterima
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

// ─── JOBS ─────────────────────────────────────────────────────────────────────

function JobsScreen({ jobs, onAdd, onEdit, onDelete }: any) {
  const [search, setSearch] = useState("");
  const filtered = jobs.filter((j: any) =>
    j.title.toLowerCase().includes(search.toLowerCase()) ||
    j.company.toLowerCase().includes(search.toLowerCase()) ||
    j.category.toLowerCase().includes(search.toLowerCase())
  );
  return (
    <div className="flex-1 overflow-y-auto">
      <div
        className="px-5 pt-5 pb-5 text-white"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <div className="flex items-center justify-between mb-3">
          <div>
            <h2 className="text-xl font-bold" style={{ fontFamily: "'Outfit', sans-serif" }}>Kelola Lowongan</h2>
            <p className="text-teal-200 text-xs">{jobs.length} lowongan aktif</p>
          </div>
          <button
            onClick={onAdd}
            className="w-9 h-9 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center border border-white/20"
          >
            <Plus size={18} />
          </button>
        </div>
        <div className="flex items-center bg-white/20 backdrop-blur-sm rounded-xl px-4 border border-white/20">
          <Search size={15} className="text-white/60 mr-2" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Cari lowongan..."
            className="flex-1 bg-transparent py-2.5 text-sm text-white outline-none placeholder-white/50"
          />
        </div>
      </div>

      <div className="px-4 py-3 space-y-2.5">
        {filtered.map((job: typeof INIT_JOBS[0]) => (
          <div key={job.id} className="bg-white rounded-2xl p-4 shadow-sm border border-teal-50">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-teal-50 to-cyan-100 rounded-xl flex items-center justify-center flex-shrink-0">
                <Building2 size={18} className="text-teal-600" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-sm text-gray-800 leading-tight">{job.title}</div>
                <div className="text-xs text-gray-400 mt-0.5 truncate">{job.company}</div>
                <div className="flex gap-1.5 mt-1.5 flex-wrap">
                  <span className="text-[11px] bg-teal-50 text-teal-700 px-2 py-0.5 rounded-full border border-teal-100">{job.category}</span>
                  <span className="text-[11px] text-gray-400 flex items-center gap-0.5"><MapPin size={9} />{job.location}</span>
                  <span className="text-[11px] text-gray-400 flex items-center gap-0.5"><Clock size={9} />{job.deadline}</span>
                </div>
                <div className="text-xs font-semibold text-teal-600 mt-1.5">{job.salary}</div>
              </div>
            </div>
            <div className="flex gap-2 mt-3 border-t border-gray-50 pt-3">
              <button
                onClick={() => onEdit(job)}
                className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-blue-50 text-blue-600 text-xs font-semibold border border-blue-100"
              >
                <Edit2 size={12} /> Edit
              </button>
              <button
                onClick={() => onDelete(job.id)}
                className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-red-50 text-red-500 text-xs font-semibold border border-red-100"
              >
                <Trash2 size={12} /> Hapus
              </button>
            </div>
          </div>
        ))}

        <button
          onClick={onAdd}
          className="w-full flex items-center justify-center gap-2 py-3.5 rounded-2xl border-2 border-dashed border-teal-200 text-teal-500 text-sm font-semibold"
        >
          <Plus size={16} /> Tambah Lowongan Baru
        </button>
      </div>
    </div>
  );
}

// ─── JOB FORM ─────────────────────────────────────────────────────────────────

function JobFormScreen({ job, onBack, onSave }: any) {
  const [form, setForm] = useState({ ...job });
  const set = (key: string, val: string) => setForm((f: any) => ({ ...f, [key]: val }));
  const isNew = job.id === 0;

  return (
    <div className="flex-1 overflow-y-auto">
      <div
        className="px-5 pt-5 pb-6 text-white flex items-center gap-3"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <button onClick={onBack} className="w-8 h-8 bg-white/20 rounded-xl flex items-center justify-center">
          <ArrowLeft size={16} />
        </button>
        <div>
          <h2 className="text-lg font-bold" style={{ fontFamily: "'Outfit', sans-serif" }}>
            {isNew ? "Tambah Lowongan" : "Edit Lowongan"}
          </h2>
          <p className="text-teal-200 text-xs">{isNew ? "Isi form di bawah ini" : "Perbarui data lowongan"}</p>
        </div>
      </div>

      <div className="px-5 py-4">
        <div className="bg-white rounded-2xl shadow-sm border border-teal-50 p-4 space-y-3">
          {[
            { key: "title", label: "Judul Lowongan", placeholder: "Misal: Frontend Developer" },
            { key: "company", label: "Nama Perusahaan", placeholder: "Misal: PT. Papua Digital" },
            { key: "salary", label: "Gaji", placeholder: "Misal: Rp 5.000.000 – Rp 8.000.000" },
          ].map((f) => (
            <div key={f.key}>
              <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1">{f.label}</label>
              <input
                value={form[f.key]}
                onChange={(e) => set(f.key, e.target.value)}
                placeholder={f.placeholder}
                className="w-full bg-teal-50 rounded-xl px-4 py-2.5 text-sm text-gray-700 outline-none border border-teal-100 placeholder-gray-300"
              />
            </div>
          ))}

          <div>
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1">Lokasi</label>
            <select value={form.location} onChange={(e) => set("location", e.target.value)} className="w-full bg-teal-50 rounded-xl px-4 py-2.5 text-sm text-gray-700 outline-none border border-teal-100">
              <option value="">Pilih lokasi...</option>
              {KABUPATEN_LIST.map((k) => <option key={k}>{k}</option>)}
            </select>
          </div>

          <div>
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1">Kategori</label>
            <select value={form.category} onChange={(e) => set("category", e.target.value)} className="w-full bg-teal-50 rounded-xl px-4 py-2.5 text-sm text-gray-700 outline-none border border-teal-100">
              <option value="">Pilih kategori...</option>
              {KARIR_LIST.map((k) => <option key={k}>{k}</option>)}
            </select>
          </div>

          <div>
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1">Deadline</label>
            <input
              type="date"
              value={form.deadline}
              onChange={(e) => set("deadline", e.target.value)}
              className="w-full bg-teal-50 rounded-xl px-4 py-2.5 text-sm text-gray-700 outline-none border border-teal-100"
            />
          </div>

          <div>
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1">Deskripsi</label>
            <textarea
              value={form.description}
              onChange={(e) => set("description", e.target.value)}
              rows={3}
              placeholder="Deskripsi pekerjaan..."
              className="w-full bg-teal-50 rounded-xl px-4 py-2.5 text-sm text-gray-700 outline-none border border-teal-100 resize-none placeholder-gray-300"
            />
          </div>

          <button
            onClick={() => onSave(form)}
            className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl text-white text-sm font-semibold shadow-lg shadow-teal-100 active:scale-[0.98] transition-all"
            style={{ background: "linear-gradient(135deg, #0b9e8e, #06c2ae)" }}
          >
            <Save size={15} /> {isNew ? "Simpan Lowongan" : "Perbarui Lowongan"}
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── APPLICATIONS ─────────────────────────────────────────────────────────────

function ApplicationsScreen({ lamaran, onToggle }: any) {
  const [filter, setFilter] = useState<"all" | "pending" | "accepted" | "rejected">("all");
  const filtered = filter === "all" ? lamaran : lamaran.filter((l: any) => l.status === filter);

  return (
    <div className="flex-1 overflow-y-auto">
      <div
        className="px-5 pt-5 pb-5 text-white"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <h2 className="text-xl font-bold mb-3" style={{ fontFamily: "'Outfit', sans-serif" }}>Kelola Lamaran</h2>
        <div className="flex gap-1.5 overflow-x-auto pb-1">
          {(["all", "pending", "accepted", "rejected"] as const).map((f) => {
            const labels = { all: "Semua", pending: "Menunggu", accepted: "Diterima", rejected: "Ditolak" };
            const count = f === "all" ? lamaran.length : lamaran.filter((l: any) => l.status === f).length;
            return (
              <button
                key={f}
                onClick={() => setFilter(f)}
                className={`flex-shrink-0 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all ${
                  filter === f ? "bg-white text-teal-700 shadow" : "bg-white/20 text-white/80"
                }`}
              >
                {labels[f]} ({count})
              </button>
            );
          })}
        </div>
      </div>

      <div className="px-4 py-3 space-y-2.5">
        {filtered.map((item: any) => {
          const badge = statusBadge(item.status);
          const ns = nextStatus(item.status);
          const nsLabel = { pending: "Terima", accepted: "Tolak", rejected: "Reset" }[item.status];
          return (
            <div key={item.id} className="bg-white rounded-2xl p-4 shadow-sm border border-teal-50">
              <div className="flex items-start gap-3 mb-3">
                <div className="w-9 h-9 bg-gradient-to-br from-teal-400 to-cyan-500 rounded-xl flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
                  {item.userName.charAt(0)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-semibold text-sm text-gray-800">{item.userName}</div>
                  <div className="text-xs text-gray-500 mt-0.5 leading-tight truncate">{item.jobTitle}</div>
                  <div className="text-xs text-gray-400 truncate">{item.company}</div>
                </div>
                <span className={`text-[11px] px-2.5 py-1 rounded-full font-semibold border flex-shrink-0 flex items-center gap-1 ${badge.bg}`}>
                  <div className={`w-1.5 h-1.5 rounded-full ${badge.dot}`} />
                  {badge.label}
                </span>
              </div>

              <div className="flex items-center justify-between border-t border-gray-50 pt-2.5">
                <div className="flex items-center gap-1 text-xs text-gray-400">
                  <Clock size={11} /> {item.date}
                </div>
                <button
                  onClick={() => onToggle(item.id)}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all ${
                    item.status === "pending"
                      ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                      : item.status === "accepted"
                      ? "bg-red-50 text-red-600 border border-red-200"
                      : "bg-amber-50 text-amber-700 border border-amber-200"
                  }`}
                >
                  <RefreshCw size={11} /> {nsLabel}
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ─── KABUPATEN (DATA MASTER) ───────────────────────────────────────────────────

function KabupatenScreen({ onToast, onNavigate }: any) {
  const [list, setList] = useState(KABUPATEN_LIST);
  const [input, setInput] = useState("");

  const add = () => {
    if (!input.trim() || list.includes(input.trim())) return;
    setList([...list, input.trim()]);
    setInput("");
    onToast("Kabupaten berhasil ditambahkan");
  };

  const remove = (k: string) => {
    setList(list.filter((x) => x !== k));
    onToast("Kabupaten dihapus");
  };

  return (
    <div className="flex-1 overflow-y-auto">
      <div
        className="px-5 pt-5 pb-5 text-white"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <h2 className="text-xl font-bold" style={{ fontFamily: "'Outfit', sans-serif" }}>Data Master</h2>
        <p className="text-teal-200 text-xs mt-0.5">Kabupaten & Spesifikasi Karir</p>
      </div>

      <div className="px-4 py-4 space-y-3">
        {/* Kabupaten */}
        <div className="bg-white rounded-2xl shadow-sm border border-teal-50 p-4">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-sm font-bold text-gray-700 flex items-center gap-2" style={{ fontFamily: "'Outfit', sans-serif" }}>
              <MapPin size={14} className="text-teal-500" /> Asal Kabupaten
            </h3>
            <span className="text-xs text-gray-400">{list.length} data</span>
          </div>
          <div className="flex gap-2 mb-3">
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Nama kabupaten baru..."
              className="flex-1 bg-teal-50 rounded-xl px-3 py-2 text-sm text-gray-700 outline-none border border-teal-100 placeholder-gray-300"
              onKeyDown={(e) => e.key === "Enter" && add()}
            />
            <button
              onClick={add}
              className="w-9 h-9 bg-teal-500 rounded-xl flex items-center justify-center text-white flex-shrink-0"
            >
              <Plus size={16} />
            </button>
          </div>
          <div className="flex flex-wrap gap-2">
            {list.map((k) => (
              <div key={k} className="flex items-center gap-1.5 bg-teal-50 text-teal-700 text-xs px-3 py-1.5 rounded-xl border border-teal-100 font-medium">
                {k}
                <button onClick={() => remove(k)} className="text-teal-400 hover:text-red-500 transition-colors">
                  <X size={11} />
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Link to Karir */}
        <div className="bg-white rounded-2xl shadow-sm border border-teal-50 p-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-bold text-gray-700 flex items-center gap-2" style={{ fontFamily: "'Outfit', sans-serif" }}>
                <Tag size={14} className="text-blue-500" /> Spesifikasi Karir
              </h3>
              <p className="text-xs text-gray-400 mt-0.5">{KARIR_LIST.length} bidang karir terdaftar</p>
            </div>
            <KarirInline onToast={onToast} />
          </div>
        </div>
      </div>
    </div>
  );
}

function KarirInline({ onToast }: any) {
  const [open, setOpen] = useState(false);
  const [list, setList] = useState(KARIR_LIST);
  const [input, setInput] = useState("");

  const add = () => {
    if (!input.trim() || list.includes(input.trim())) return;
    setList([...list, input.trim()]);
    setInput("");
    onToast("Bidang karir ditambahkan");
  };

  if (!open) {
    return (
      <button onClick={() => setOpen(true)} className="text-xs text-teal-600 font-semibold flex items-center gap-1">
        Kelola <ChevronDown size={12} />
      </button>
    );
  }

  return (
    <button onClick={() => setOpen(false)} className="text-xs text-gray-400 font-semibold">
      Tutup
    </button>
  );
}

function KarirScreen({ onToast, onBack }: any) {
  const [list, setList] = useState(KARIR_LIST);
  const [input, setInput] = useState("");

  const add = () => {
    if (!input.trim() || list.includes(input.trim())) return;
    setList([...list, input.trim()]);
    setInput("");
    onToast("Bidang karir berhasil ditambahkan");
  };

  const remove = (k: string) => {
    setList(list.filter((x) => x !== k));
    onToast("Bidang karir dihapus");
  };

  return (
    <div className="flex-1 overflow-y-auto">
      <div
        className="px-5 pt-5 pb-5 text-white flex items-center gap-3"
        style={{ background: "linear-gradient(135deg, #0b4f4a 0%, #0b9e8e 100%)" }}
      >
        <button onClick={onBack} className="w-8 h-8 bg-white/20 rounded-xl flex items-center justify-center">
          <ArrowLeft size={16} />
        </button>
        <div>
          <h2 className="text-lg font-bold" style={{ fontFamily: "'Outfit', sans-serif" }}>Spesifikasi Karir</h2>
          <p className="text-teal-200 text-xs">{list.length} bidang terdaftar</p>
        </div>
      </div>
      <div className="px-4 py-4">
        <div className="bg-white rounded-2xl shadow-sm border border-teal-50 p-4">
          <div className="flex gap-2 mb-4">
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Nama bidang karir baru..."
              className="flex-1 bg-teal-50 rounded-xl px-3 py-2 text-sm text-gray-700 outline-none border border-teal-100 placeholder-gray-300"
              onKeyDown={(e) => e.key === "Enter" && add()}
            />
            <button onClick={add} className="w-9 h-9 bg-teal-500 rounded-xl flex items-center justify-center text-white flex-shrink-0">
              <Plus size={16} />
            </button>
          </div>
          <div className="space-y-2">
            {list.map((k) => (
              <div key={k} className="flex items-center justify-between py-2.5 px-3 bg-teal-50 rounded-xl border border-teal-100">
                <span className="text-sm text-gray-700 font-medium flex items-center gap-2">
                  <Tag size={13} className="text-teal-500" /> {k}
                </span>
                <button onClick={() => remove(k)} className="text-gray-300 hover:text-red-500 transition-colors">
                  <Trash2 size={14} />
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
