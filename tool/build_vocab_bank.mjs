import fs from 'node:fs';
import path from 'node:path';

const repoRoot = process.cwd();
const sourceDir = process.env.ARABIC_VOCAB_SOURCE_DIR ?? '/tmp/arabic-vocab-api/json';
const outputPath = path.join(
  repoRoot,
  'lib/features/game/data/default_puzzles.dart',
);

const categoryMap = new Map([
  ['animals.json', 'الحيوانات'],
  ['city_and_transportation.json', 'المدينة والتنقل'],
  ['clothing.json', 'الملابس'],
  ['colors.json', 'الألوان'],
  ['crime_and_punishment.json', 'الجريمة والعقوبة'],
  ['education.json', 'التعليم'],
  ['emotions__and__personality_traits.json', 'المشاعر والصفات'],
  ['food.json', 'الطعام'],
  ['geography.json', 'الجغرافيا'],
  ['government_and_politics.json', 'الحكومة والسياسة'],
  ['human_body.json', 'جسم الإنسان'],
  ['mankind_and_kinship.json', 'الناس والعائلة'],
  ['media.json', 'الإعلام والفنون'],
  ['media_2.json', 'الإعلام والفنون'],
  ['media_3.json', 'الإعلام والفنون'],
  ['media_and_the_arts.json', 'الإعلام والفنون'],
  ['medicine.json', 'الصحة'],
  ['nature__and__weather.json', 'الطبيعة والطقس'],
  ['religion.json', 'الدين'],
  ['sports__and__hobbies.json', 'الرياضة والهوايات'],
  ['technology.json', 'التقنية'],
  ['time.json', 'الزمن'],
  ['vocabulary_from_around_the_house.json', 'المنزل'],
  ['war.json', 'الحرب'],
  ['work_and_money.json', 'العمل والمال'],
]);

const targets = new Map([
  [3, 500],
  [4, 400],
  [5, 300],
  [6, 200],
]);

const preferredSeeds = [
  { word: 'حديقة', category: 'الطبيعة والطقس' },
  { word: 'مدرسة', category: 'التعليم' },
  { word: 'مكتبة', category: 'الإعلام والفنون' },
  { word: 'جامعة', category: 'التعليم' },
  { word: 'بحيرة', category: 'الطبيعة والطقس' },
  { word: 'مدينة', category: 'المدينة والتنقل' },
  { word: 'مسجد', category: 'الدين' },
  { word: 'تفاحة', category: 'الطعام' },
];

const supplementalSeeds = [
  { word: 'جرس', category: 'المنزل' },
  { word: 'غيم', category: 'الطبيعة والطقس' },
  { word: 'صخر', category: 'الطبيعة والطقس' },
  { word: 'ورد', category: 'الطبيعة والطقس' },
  { word: 'زهر', category: 'الطبيعة والطقس' },
  { word: 'نخل', category: 'الطبيعة والطقس' },
  { word: 'ليل', category: 'الطبيعة والطقس' },
  { word: 'صبح', category: 'الطبيعة والطقس' },
  { word: 'ضوء', category: 'الطبيعة والطقس' },
  { word: 'جمر', category: 'الطبيعة والطقس' },
  { word: 'غار', category: 'الطبيعة والطقس' },
  { word: 'كهف', category: 'الطبيعة والطقس' },
  { word: 'نبع', category: 'الطبيعة والطقس' },
  { word: 'وحل', category: 'الطبيعة والطقس' },
  { word: 'ندى', category: 'الطبيعة والطقس' },
  { word: 'عقل', category: 'المشاعر والصفات' },
  { word: 'نبض', category: 'جسم الإنسان' },
  { word: 'حلم', category: 'المشاعر والصفات' },
  { word: 'خوف', category: 'المشاعر والصفات' },
  { word: 'فرح', category: 'المشاعر والصفات' },
  { word: 'حزن', category: 'المشاعر والصفات' },
  { word: 'صبر', category: 'المشاعر والصفات' },
  { word: 'أمل', category: 'المشاعر والصفات' },
  { word: 'أنس', category: 'المشاعر والصفات' },
  { word: 'فخر', category: 'المشاعر والصفات' },
  { word: 'عسل', category: 'الطعام' },
  { word: 'تمر', category: 'الطعام' },
  { word: 'أرز', category: 'الطعام' },
  { word: 'فول', category: 'الطعام' },
  { word: 'لوز', category: 'الطعام' },
  { word: 'حمص', category: 'الطعام' },
  { word: 'عدس', category: 'الطعام' },
  { word: 'سمن', category: 'الطعام' },
  { word: 'بلح', category: 'الطعام' },
  { word: 'حبر', category: 'التعليم' },
  { word: 'لوح', category: 'التعليم' },
  { word: 'تاج', category: 'الملابس' },
  { word: 'درع', category: 'الحرب' },
  { word: 'كأس', category: 'المنزل' },
  { word: 'مقص', category: 'المنزل' },
  { word: 'قيد', category: 'المنزل' },
  { word: 'وتر', category: 'الإعلام والفنون' },
  { word: 'شمع', category: 'المنزل' },
  { word: 'حبل', category: 'المنزل' },
  { word: 'أسد', category: 'الحيوانات' },
  { word: 'بطة', category: 'الحيوانات' },
  { word: 'وزة', category: 'الحيوانات' },
  { word: 'نحل', category: 'الحيوانات' },
  { word: 'دود', category: 'الحيوانات' },
  { word: 'فرس', category: 'الحيوانات' },
  { word: 'ظبي', category: 'الحيوانات' },
  { word: 'بنت', category: 'الناس والعائلة' },
  { word: 'فتى', category: 'الناس والعائلة' },
  { word: 'خبر', category: 'الإعلام والفنون' },
  { word: 'خزف', category: 'الإعلام والفنون' },
  { word: 'طبل', category: 'الإعلام والفنون' },
  { word: 'آية', category: 'الدين' },
  { word: 'مرة', category: 'الزمن' },
  { word: 'ثوب', category: 'الملابس' },
  { word: 'درب', category: 'المدينة والتنقل' },
  { word: 'لثة', category: 'جسم الإنسان' },
  { word: 'قفا', category: 'جسم الإنسان' },
  { word: 'مرئ', category: 'جسم الإنسان' },
  { word: 'نمش', category: 'جسم الإنسان' },
  { word: 'ظفر', category: 'جسم الإنسان' },
  { word: 'جنس', category: 'الناس والعائلة' },
  { word: 'مهن', category: 'العمل والمال' },
  { word: 'قوس', category: 'الحرب' },
  { word: 'سوط', category: 'الحرب' },
  { word: 'وتر', category: 'الإعلام والفنون' },
  { word: 'رف', category: 'المنزل' },
  { word: 'جرة', category: 'المنزل' },
  { word: 'جرن', category: 'المنزل' },
  { word: 'دلو', category: 'المنزل' },
  { word: 'سطل', category: 'المنزل' },
  { word: 'فرش', category: 'المنزل' },
  { word: 'صحن', category: 'المنزل' },
  { word: 'قفل', category: 'المنزل' },
  { word: 'وتد', category: 'المنزل' },
  { word: 'سرج', category: 'المنزل' },
  { word: 'شال', category: 'الملابس' },
  { word: 'وشم', category: 'الملابس' },
  { word: 'جرو', category: 'الحيوانات' },
  { word: 'ريم', category: 'الحيوانات' },
  { word: 'بغل', category: 'الحيوانات' },
  { word: 'بوم', category: 'الحيوانات' },
  { word: 'وبر', category: 'الحيوانات' },
  { word: 'مهر', category: 'الحيوانات' },
  { word: 'سوس', category: 'الحيوانات' },
  { word: 'حبق', category: 'الطعام' },
  { word: 'لبن', category: 'الطعام' },
  { word: 'سمن', category: 'الطعام' },
  { word: 'كرم', category: 'الطعام' },
  { word: 'دبس', category: 'الطعام' },
  { word: 'دوح', category: 'الطبيعة والطقس' },
  { word: 'روض', category: 'الطبيعة والطقس' },
  { word: 'سرو', category: 'الطبيعة والطقس' },
  { word: 'سدر', category: 'الطبيعة والطقس' },
  { word: 'وهد', category: 'الطبيعة والطقس' },
  { word: 'صدى', category: 'الطبيعة والطقس' },
  { word: 'فلك', category: 'الطبيعة والطقس' },
  { word: 'صدف', category: 'الطبيعة والطقس' },
  { word: 'شحم', category: 'جسم الإنسان' },
  { word: 'فخذ', category: 'جسم الإنسان' },
  { word: 'خصر', category: 'جسم الإنسان' },
  { word: 'ردف', category: 'جسم الإنسان' },
  { word: 'عضد', category: 'جسم الإنسان' },
  { word: 'وتر', category: 'جسم الإنسان' },
  { word: 'عم', category: 'الناس والعائلة' },
  { word: 'خال', category: 'الناس والعائلة' },
  { word: 'مكة', category: 'الجغرافيا' },
  { word: 'عدن', category: 'الجغرافيا' },
  { word: 'حلب', category: 'الجغرافيا' },
  { word: 'صور', category: 'الجغرافيا' },
  { word: 'قنا', category: 'الجغرافيا' },
  { word: 'أبها', category: 'الجغرافيا' },
  { word: 'نوت', category: 'الإعلام والفنون' },
  { word: 'عود', category: 'الإعلام والفنون' },
  { word: 'لحن', category: 'الإعلام والفنون' },
  { word: 'ناي', category: 'الإعلام والفنون' },
  { word: 'حرف', category: 'التعليم' },
  { word: 'اسم', category: 'التعليم' },
  { word: 'لقب', category: 'التعليم' },
  { word: 'رمز', category: 'التعليم' },
  { word: 'كنز', category: 'المنزل' },
  { word: 'كوخ', category: 'المنزل' },
  { word: 'قبو', category: 'المنزل' },
  { word: 'كشك', category: 'المنزل' },
  { word: 'مهد', category: 'المنزل' },
  { word: 'سرب', category: 'الحيوانات' },
  { word: 'وكر', category: 'الحيوانات' },
  { word: 'نرد', category: 'الرياضة والهوايات' },
  { word: 'قصب', category: 'الطبيعة والطقس' },
  { word: 'قاع', category: 'الطبيعة والطقس' },
  { word: 'عمق', category: 'الطبيعة والطقس' },
  { word: 'جوف', category: 'الطبيعة والطقس' },
  { word: 'شطر', category: 'التعليم' },
  { word: 'حلي', category: 'الملابس' },
  { word: 'عرش', category: 'المدينة والتنقل' },
  { word: 'سهم', category: 'الحرب' },
  { word: 'عهد', category: 'الحكومة والسياسة' },
  { word: 'قنب', category: 'الحرب' },
  { word: 'جيب', category: 'الملابس' },
  { word: 'أخطبوط', category: 'الحيوانات' },
  { word: 'مهرجان', category: 'الإعلام والفنون' },
  { word: 'مستشفى', category: 'الصحة' },
  { word: 'صيدلية', category: 'الصحة' },
  { word: 'تأشيرة', category: 'المدينة والتنقل' },
  { word: 'مروحية', category: 'المدينة والتنقل' },
  { word: 'محاكمة', category: 'الجريمة والعقوبة' },
  { word: 'زنزانة', category: 'الجريمة والعقوبة' },
  { word: 'اختلاس', category: 'الجريمة والعقوبة' },
  { word: 'احتيال', category: 'الجريمة والعقوبة' },
  { word: 'ابتزاز', category: 'الجريمة والعقوبة' },
  { word: 'كراهية', category: 'المشاعر والصفات' },
  { word: 'تنهيدة', category: 'المشاعر والصفات' },
  { word: 'برتقال', category: 'الطعام' },
  { word: 'أناناس', category: 'الطعام' },
  { word: 'مكرونة', category: 'الطعام' },
  { word: 'بقدونس', category: 'الطعام' },
  { word: 'زنجبيل', category: 'الطعام' },
  { word: 'زعفران', category: 'الطعام' },
  { word: 'ارتفاع', category: 'الجغرافيا' },
  { word: 'محافظة', category: 'الجغرافيا' },
  { word: 'أوروبا', category: 'الجغرافيا' },
  { word: 'طرابلس', category: 'الجغرافيا' },
  { word: 'بنغازي', category: 'الجغرافيا' },
  { word: 'فلسطين', category: 'الجغرافيا' },
  { word: 'برلمان', category: 'الحكومة والسياسة' },
  { word: 'انتخاب', category: 'الحكومة والسياسة' },
  { word: 'شفافية', category: 'الحكومة والسياسة' },
  { word: 'مساهمة', category: 'الحكومة والسياسة' },
  { word: 'مناظرة', category: 'الحكومة والسياسة' },
  { word: 'مساواة', category: 'الحكومة والسياسة' },
  { word: 'عنصرية', category: 'الحكومة والسياسة' },
  { word: 'عبودية', category: 'الحكومة والسياسة' },
  { word: 'اجتماع', category: 'الإعلام والفنون' },
  { word: 'مبادرة', category: 'الإعلام والفنون' },
  { word: 'اقتراح', category: 'الإعلام والفنون' },
  { word: 'مظاهرة', category: 'الإعلام والفنون' },
  { word: 'اعتصام', category: 'الإعلام والفنون' },
  { word: 'امتياز', category: 'الإعلام والفنون' },
  { word: 'انهيار', category: 'الإعلام والفنون' },
  { word: 'منافسة', category: 'الإعلام والفنون' },
  { word: 'مسابقة', category: 'الإعلام والفنون' },
  { word: 'رفاهية', category: 'الإعلام والفنون' },
  { word: 'احتمال', category: 'الإعلام والفنون' },
  { word: 'اقتصاد', category: 'العمل والمال' },
  { word: 'احتكار', category: 'العمل والمال' },
  { word: 'احتواء', category: 'الإعلام والفنون' },
  { word: 'اضطراب', category: 'الإعلام والفنون' },
  { word: 'مؤامرة', category: 'الإعلام والفنون' },
  { word: 'أولوية', category: 'الإعلام والفنون' },
  { word: 'اختراق', category: 'التقنية' },
  { word: 'محاذاة', category: 'التقنية' },
  { word: 'انحراف', category: 'الإعلام والفنون' },
  { word: 'موسيقى', category: 'الإعلام والفنون' },
  { word: 'مراجعة', category: 'الإعلام والفنون' },
  { word: 'مغامرة', category: 'الإعلام والفنون' },
  { word: 'غيبوبة', category: 'الصحة' },
  { word: 'مستنقع', category: 'الطبيعة والطقس' },
  { word: 'ترنيمة', category: 'الدين' },
  { word: 'مباراة', category: 'الرياضة والهوايات' },
  { word: 'تمريرة', category: 'الرياضة والهوايات' },
  { word: 'بيسبول', category: 'الرياضة والهوايات' },
  { word: 'ملاكمة', category: 'الرياضة والهوايات' },
  { word: 'مصارعة', category: 'الرياضة والهوايات' },
  { word: 'فبراير', category: 'الزمن' },
  { word: 'أكتوبر', category: 'الزمن' },
  { word: 'نوفمبر', category: 'الزمن' },
  { word: 'حزيران', category: 'الزمن' },
  { word: 'برمهات', category: 'الزمن' },
  { word: 'برمودة', category: 'الزمن' },
  { word: 'كهرباء', category: 'المنزل' },
  { word: 'ماسورة', category: 'المنزل' },
  { word: 'قيشاني', category: 'المنزل' },
  { word: 'بطانية', category: 'المنزل' },
  { word: 'تسريحة', category: 'المنزل' },
  { word: 'ماكياج', category: 'المنزل' },
  { word: 'قنديل', category: 'المنزل' },
  { word: 'نظارة', category: 'المنزل' },
  { word: 'طاولة', category: 'المنزل' },
  { word: 'مفتاح', category: 'المنزل' },
  { word: 'صندوق', category: 'المنزل' },
  { word: 'سلسلة', category: 'المنزل' },
  { word: 'مقلمة', category: 'التعليم' },
  { word: 'محبرة', category: 'التعليم' },
  { word: 'خريطة', category: 'التعليم' },
  { word: 'شمعدان', category: 'المنزل' },
  { word: 'مغسلة', category: 'المنزل' },
  { word: 'مرحاض', category: 'المنزل' },
  { word: 'مدفأة', category: 'المنزل' },
  { word: 'غسالة', category: 'المنزل' },
  { word: 'مصفوفة', category: 'التعليم' },
  { word: 'مقصورة', category: 'المنزل' },
  { word: 'مقطورة', category: 'المدينة والتنقل' },
  { word: 'مصيدة', category: 'المنزل' },
  { word: 'مبخرة', category: 'المنزل' },
  { word: 'مزهرية', category: 'المنزل' },
  { word: 'مزراب', category: 'المنزل' },
  { word: 'مطرقة', category: 'المنزل' },
  { word: 'بطارية', category: 'التقنية' },
  { word: 'بوصلة', category: 'التقنية' },
  { word: 'قلادة', category: 'الملابس' },
  { word: 'خاتمة', category: 'التعليم' },
  { word: 'ضفيرة', category: 'الملابس' },
  { word: 'سبابة', category: 'جسم الإنسان' },
  { word: 'معجون', category: 'المنزل' },
  { word: 'بلورة', category: 'المنزل' },
  { word: 'لؤلؤة', category: 'المنزل' },
  { word: 'شجيرة', category: 'الطبيعة والطقس' },
  { word: 'ليمونة', category: 'الطعام' },
  { word: 'جوهرة', category: 'المنزل' },
  { word: 'تمثال', category: 'الإعلام والفنون' },
  { word: 'نافورة', category: 'المدينة والتنقل' },
  { word: 'منارة', category: 'المدينة والتنقل' },
  { word: 'حاسوب', category: 'التقنية' },
  { word: 'مسبار', category: 'التقنية' },
  { word: 'برميل', category: 'المنزل' },
  { word: 'قاطرة', category: 'المدينة والتنقل' },
  { word: 'سفارة', category: 'الحكومة والسياسة' },
  { word: 'كمثرة', category: 'الطعام' },
  { word: 'بطيخة', category: 'الطعام' },
  { word: 'عجينة', category: 'الطعام' },
  { word: 'مزولة', category: 'الزمن' },
  { word: 'استماع', category: 'الإعلام والفنون' },
  { word: 'ابتسام', category: 'المشاعر والصفات' },
  { word: 'احترام', category: 'المشاعر والصفات' },
  { word: 'اهتمام', category: 'المشاعر والصفات' },
  { word: 'انتباه', category: 'التعليم' },
  { word: 'اختيار', category: 'التعليم' },
  { word: 'اكتساب', category: 'التعليم' },
  { word: 'ارتباط', category: 'الناس والعائلة' },
  { word: 'اقتباس', category: 'الإعلام والفنون' },
  { word: 'انتقال', category: 'المدينة والتنقل' },
  { word: 'اشتراك', category: 'العمل والمال' },
  { word: 'اندماج', category: 'الناس والعائلة' },
  { word: 'انسجام', category: 'المشاعر والصفات' },
  { word: 'اشتعال', category: 'الطبيعة والطقس' },
  { word: 'انتظام', category: 'التعليم' },
  { word: 'انتساب', category: 'التعليم' },
  { word: 'افتخار', category: 'المشاعر والصفات' },
  { word: 'اعتراف', category: 'الإعلام والفنون' },
  { word: 'ابتكار', category: 'التقنية' },
  { word: 'اكتشاف', category: 'التقنية' },
  { word: 'اقتناء', category: 'المنزل' },
  { word: 'انعكاس', category: 'الإعلام والفنون' },
  { word: 'انشغال', category: 'العمل والمال' },
  { word: 'استقبال', category: 'المدينة والتنقل' },
  { word: 'استئجار', category: 'العمل والمال' },
  { word: 'استقرار', category: 'المدينة والتنقل' },
  { word: 'استثمار', category: 'العمل والمال' },
  { word: 'استبعاد', category: 'الإعلام والفنون' },
  { word: 'استفهام', category: 'التعليم' },
  { word: 'استعداد', category: 'التعليم' },
  { word: 'استعجال', category: 'المشاعر والصفات' },
  { word: 'استهلاك', category: 'العمل والمال' },
  { word: 'انتماء', category: 'الناس والعائلة' },
  { word: 'ازدهار', category: 'الطبيعة والطقس' },
  { word: 'ازعاج', category: 'المشاعر والصفات' },
  { word: 'إلهام', category: 'الإعلام والفنون' },
  { word: 'إجهاد', category: 'الصحة' },
  { word: 'إكرام', category: 'الناس والعائلة' },
  { word: 'إمطار', category: 'الطبيعة والطقس' },
  { word: 'إحسان', category: 'الناس والعائلة' },
  { word: 'إجلال', category: 'الدين' },
  { word: 'استناد', category: 'التعليم' },
  { word: 'انطلاق', category: 'المدينة والتنقل' },
  { word: 'انعطاف', category: 'المدينة والتنقل' },
  { word: 'انضمام', category: 'الناس والعائلة' },
  { word: 'انبساط', category: 'المشاعر والصفات' },
  { word: 'انقباض', category: 'جسم الإنسان' },
  { word: 'انتعاش', category: 'الصحة' },
  { word: 'انكسار', category: 'الطبيعة والطقس' },
  { word: 'انتشار', category: 'الإعلام والفنون' },
  { word: 'التزام', category: 'التعليم' },
  { word: 'التفاف', category: 'المدينة والتنقل' },
  { word: 'امتداد', category: 'الطبيعة والطقس' },
  { word: 'امتناع', category: 'المشاعر والصفات' },
  { word: 'امتنان', category: 'المشاعر والصفات' },
  { word: 'امتلاء', category: 'الطعام' },
  { word: 'اقتران', category: 'الناس والعائلة' },
  { word: 'اقتدار', category: 'المشاعر والصفات' },
  { word: 'اقتسام', category: 'الناس والعائلة' },
  { word: 'اقتصاص', category: 'الجريمة والعقوبة' },
  { word: 'اكتمال', category: 'التعليم' },
  { word: 'التهاب', category: 'الصحة' },
  { word: 'التحاق', category: 'التعليم' },
  { word: 'انقلاب', category: 'الحرب' },
  { word: 'مقاومة', category: 'الحرب' },
  { word: 'احتلال', category: 'الحرب' },
  { word: 'بندقية', category: 'الحرب' },
  { word: 'انفجار', category: 'الحرب' },
  { word: 'مفرقعة', category: 'الحرب' },
  { word: 'اشتباك', category: 'الحرب' },
  { word: 'اعتداء', category: 'الحرب' },
  { word: 'انتصار', category: 'الحرب' },
  { word: 'معاهدة', category: 'الحرب' },
  { word: 'جوهرجي', category: 'العمل والمال' },
];

const customDefinitions = {
  'حديقة': 'مساحة مزروعة تضم نباتات وأزهاراً وتُستخدم للراحة أو التنزه.',
  'مدرسة': 'مكان مخصص للتعلّم والدراسة يجتمع فيه الطلاب مع المعلمين.',
  'مكتبة': 'مكان تُجمع فيه الكتب والمراجع للقراءة أو الاستعارة.',
  'جامعة': 'مؤسسة تعليم عالٍ تقدم تخصصات أكاديمية ومهنية متنوعة.',
  'بحيرة': 'مسطح مائي تحيط به اليابسة من الجهات المختلفة.',
  'مدينة': 'منطقة سكانية كبيرة تضم أحياءً وخدمات ومرافق متعددة.',
  'مسجد': 'مكان مخصص للصلاة والعبادة عند المسلمين.',
  'تفاحة': 'ثمرة معروفة بطعمها الحلو أو الحامض وتؤكل طازجة أو مطهية.',
  'ملف': 'مجموعة من البيانات أو المستندات تُحفظ باسم محدد على جهاز أو وسيط تخزين.',
  'فأرة': 'أداة إدخال تُستخدم لتحريك المؤشر وتنفيذ الأوامر على الشاشة.',
  'رقمي': 'ما يُمثَّل أو يُعالج بصيغة رقمية داخل الأنظمة الإلكترونية.',
  'وهمي': 'غير حقيقي مادياً، ويُستخدم لوصف بيئة أو عنصر مُنشأ برمجياً.',
  'نظام': 'مجموعة مترابطة من المكونات أو التعليمات تعمل معاً لتنفيذ وظيفة محددة.',
  'حاسب': 'جهاز إلكتروني يعالج البيانات وينفذ العمليات وفق برامج محددة.',
  'مضيف': 'جهاز أو خدمة تستقبل المواقع أو التطبيقات أو الموارد على الشبكة.',
  'مزود': 'جهة أو نظام يقدّم خدمة تقنية مثل الاتصال أو الاستضافة أو البيانات.',
  'رموز': 'علامات أو شفرات تُستخدم لتمثيل أوامر أو معانٍ داخل الأنظمة البرمجية.',
  'مجلد': 'حاوية تنظيمية تُستخدم لترتيب الملفات داخل نظام التشغيل.',
  'رصيد': 'مقدار متاح من المال أو البيانات أو الدقائق في خدمة رقمية.',
  'نسخة': 'صورة مطابقة من ملف أو بيانات تُستخدم للحفظ أو المشاركة أو النسخ الاحتياطي.',
  'مسبار': 'أداة أو مركبة مزودة بأجهزة قياس تُستخدم لاستكشاف بيئة بعيدة وجمع البيانات.',
  'حاسوب': 'جهاز إلكتروني يستقبل البيانات ويعالجها ويعرض النتائج للمستخدم.',
  'معالج': 'المكوّن المسؤول عن تنفيذ التعليمات والعمليات الأساسية داخل الحاسوب.',
  'طباعة': 'عملية إخراج النصوص أو الصور من الجهاز إلى الورق أو وسيط مادي مشابه.',
  'قاعدة': 'بنية منظّمة تُحفظ فيها البيانات أو القواعد لسهولة الرجوع والمعالجة.',
  'منتدى': 'مساحة نقاش على الإنترنت يشارك فيها المستخدمون الأسئلة والآراء والمحتوى.',
  'مدونة': 'منصة نشر رقمية تُعرض فيها المقالات أو التحديثات بترتيب زمني.',
  'دردشة': 'محادثة فورية تُجرى عبر تطبيق أو خدمة تواصل رقمية.',
  'تعليق': 'نص قصير يضيفه المستخدم للتفاعل مع محتوى منشور على منصة رقمية.',
  'تصميم': 'تخطيط بصري أو وظيفي لواجهة أو منتج أو تجربة رقمية.',
  'متصفح': 'برنامج يُستخدم لفتح صفحات الويب والتنقل بين مواقع الإنترنت.',
  'كاميرا': 'جهاز يُستخدم لالتقاط الصور أو الفيديو رقمياً وحفظها أو نقلها.',
  'بطارية': 'وحدة تخزن الطاقة الكهربائية لتشغيل الأجهزة الإلكترونية عند الحاجة.',
  'ابتكار': 'تطوير فكرة أو حل جديد يضيف قيمة عملية أو تقنية.',
  'اكتشاف': 'الوصول إلى معرفة أو نتيجة جديدة عبر البحث أو التجربة أو الملاحظة.',
};

const arabicOnly = /^[\u0621-\u064A\u0671]+$/u;
const blockedWords = new Set([
  'أغنام',
  'فئران',
  'جواميس',
  'قراميط',
  'أبحاث',
  'مناهج',
  'ندوات',
  'ظواهر',
  'أقمشة',
  'أحذية',
  'أقدام',
  'اشخاص',
  'أشخاص',
  'أطفال',
  'أحفاد',
  'شابات',
  'شبان',
  'رؤساء',
  'تصرفات',
  'بيانات',
  'مفردات',
  'مسلحون',
  'أطيان',
  'أسنان',
  'اسنان',
  'كروهات',
  'فرامة',
]);

function normalizeWord(rawWord) {
  return rawWord
    .trim()
    .replace(/ـ/gu, '')
    .replace(/[\u064B-\u065F\u0670]/gu, '');
}

function countLetters(word) {
  return [...word].length;
}

function hasAttachedPronoun(word) {
  const suffixes = ['كما', 'كم', 'كن', 'هم', 'هن', 'ها', 'نا', 'ك', 'ه'];
  return suffixes.some(
    (suffix) => word.length > suffix.length + 1 && word.endsWith(suffix),
  );
}

function isStrictSingularEnglishLabel(label) {
  const normalized = label.trim().toLowerCase();
  if (!normalized) {
    return false;
  }

  if (
    normalized.includes('|') ||
    normalized.includes('/') ||
    normalized.includes('__') ||
    /\b(and|or|with|from|to|of|by)\b/.test(normalized)
  ) {
    return false;
  }

  if (normalized.endsWith('s') && !normalized.endsWith('ss')) {
    return false;
  }

  return true;
}

function createBuckets() {
  const result = new Map();
  for (const modeLength of targets.keys()) {
    result.set(modeLength, new Map());
  }
  return result;
}

function ensureBucket(buckets, length, category) {
  const modeBuckets = buckets.get(length);
  if (!modeBuckets.has(category)) {
    modeBuckets.set(category, []);
  }
  return modeBuckets.get(category);
}

function pushUniqueWord(bucket, seen, word) {
  if (seen.has(word)) {
    return;
  }

  seen.add(word);
  bucket.push(word);
}

function populateSourceBuckets() {
  const buckets = createBuckets();
  const seenByLength = new Map(
    [...targets.keys()].map((length) => [length, new Set()]),
  );

  for (const [fileName, category] of categoryMap.entries()) {
    const filePath = path.join(sourceDir, fileName);
    if (!fs.existsSync(filePath)) {
      continue;
    }

    const rows = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    for (const row of rows.slice(1)) {
      const rawWord = row.standardArabic ?? '';
      if (!rawWord.trim() || /[|/]/u.test(rawWord) || /\s/u.test(rawWord)) {
        continue;
      }

      const word = normalizeWord(rawWord);
      if (
        !arabicOnly.test(word) ||
        hasAttachedPronoun(word) ||
        blockedWords.has(word)
      ) {
        continue;
      }

      const length = countLetters(word);
      if (!targets.has(length)) {
        continue;
      }

      if (!isStrictSingularEnglishLabel(row.english ?? '')) {
        continue;
      }

      const bucket = ensureBucket(buckets, length, category);
      pushUniqueWord(bucket, seenByLength.get(length), word);
    }
  }

  return buckets;
}

function addManualSeeds(buckets, seeds) {
  const seenByLength = new Map(
    [...targets.keys()].map((length) => {
      const seen = new Set();
      const modeBuckets = buckets.get(length);
      for (const words of modeBuckets.values()) {
        for (const word of words) {
          seen.add(word);
        }
      }
      return [length, seen];
    }),
  );

  for (const seed of seeds) {
    const word = normalizeWord(seed.word);
    const length = countLetters(word);
    if (
      !targets.has(length) ||
      !arabicOnly.test(word) ||
      hasAttachedPronoun(word) ||
      blockedWords.has(word)
    ) {
      continue;
    }

    const bucket = ensureBucket(buckets, length, seed.category);
    pushUniqueWord(bucket, seenByLength.get(length), word);
  }
}

function selectWordsForLength(buckets, targetLength) {
  const modeBuckets = buckets.get(targetLength);
  const orderedCategories = [...categoryMap.values()].filter(
    (category, index, all) =>
      all.indexOf(category) === index && modeBuckets.has(category),
  );
  const indexes = new Map(orderedCategories.map((category) => [category, 0]));
  const selected = [];
  const selectedWords = new Set();
  const targetCount = targets.get(targetLength);

  const preferredForLength = preferredSeeds.filter(
    (seed) => countLetters(seed.word) === targetLength,
  );
  for (const seed of preferredForLength) {
    if (selectedWords.has(seed.word)) {
      continue;
    }
    selected.push({ word: normalizeWord(seed.word), category: seed.category });
    selectedWords.add(normalizeWord(seed.word));
  }

  while (selected.length < targetCount) {
    let advanced = false;

    for (const category of orderedCategories) {
      const words = modeBuckets.get(category) ?? [];
      const startIndex = indexes.get(category) ?? 0;
      let word = null;

      for (let i = startIndex; i < words.length; i += 1) {
        if (selectedWords.has(words[i])) {
          continue;
        }

        word = words[i];
        indexes.set(category, i + 1);
        break;
      }

      if (word == null) {
        continue;
      }

      selected.push({ word, category });
      selectedWords.add(word);
      advanced = true;

      if (selected.length >= targetCount) {
        break;
      }
    }

    if (!advanced) {
      break;
    }
  }

  if (selected.length !== targetCount) {
    throw new Error(
      `Unable to assemble ${targetCount} words for length ${targetLength}; built ${selected.length}.`,
    );
  }

  return selected;
}

function groupSelectedWords(selected) {
  const grouped = new Map();
  for (const item of selected) {
    if (!grouped.has(item.category)) {
      grouped.set(item.category, []);
    }
    grouped.get(item.category).push(item.word);
  }
  return grouped;
}

function dartString(value) {
  return `'${value.replaceAll("'", "\\'")}'`;
}

function emitMode(categoryGroups) {
  const lines = [];
  for (const [category, words] of categoryGroups.entries()) {
    lines.push(
      `      ..._category(${dartString(category)}, [${words
        .map(dartString)
        .join(', ')}]),`,
    );
  }
  return lines.join('\n');
}

function emitFile(groupedByLength) {
  return `import 'package:arabic_wordly/features/game/domain/game_models.dart';

// Generated from https://github.com/selmetwa/arabic-vocab-api with a small
// reviewed supplement to reach exact per-mode counts while keeping singular,
// single-token Arabic words only.
Map<GameMode, List<ArabicPuzzle>> buildDefaultPuzzles() {
  return {
    GameMode.threeLetters: [
${emitMode(groupedByLength.get(3))}
    ],
    GameMode.fourLetters: [
${emitMode(groupedByLength.get(4))}
    ],
    GameMode.fiveLetters: [
${emitMode(groupedByLength.get(5))}
    ],
    GameMode.sixLetters: [
${emitMode(groupedByLength.get(6))}
    ],
  };
}

List<ArabicPuzzle> _category(String category, List<String> words) {
  return words
      .map(
        (word) => ArabicPuzzle(
          word: word,
          category: category,
          definition: _definitionForWord(word, category),
        ),
      )
      .toList(growable: false);
}

String? _definitionForWord(String word, String category) {
  const customDefinitions = <String, String>{
    ${Object.entries(customDefinitions)
      .map(([word, definition]) => `${dartString(word)}: ${dartString(definition)}`)
      .join(',\n    ')},
  };

  return customDefinitions[word];
}
`;
}

function main() {
  if (!fs.existsSync(sourceDir)) {
    throw new Error(`Source directory not found: ${sourceDir}`);
  }

  const buckets = populateSourceBuckets();
  addManualSeeds(buckets, preferredSeeds);
  addManualSeeds(buckets, supplementalSeeds);

  const groupedByLength = new Map();
  for (const targetLength of targets.keys()) {
    const selected = selectWordsForLength(buckets, targetLength);
    groupedByLength.set(targetLength, groupSelectedWords(selected));
  }

  fs.writeFileSync(outputPath, emitFile(groupedByLength));
  console.log(`Wrote ${outputPath}`);
}

main();
