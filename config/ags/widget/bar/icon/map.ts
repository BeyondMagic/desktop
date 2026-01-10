import { config } from "../../../app";

type CategoryMatcher = {
	pattern: RegExp;
	replace: string;
};

const categoryMatchers: CategoryMatcher[] = config.categories.flatMap((category) =>
	category.find.map((pattern) => ({
		pattern: new RegExp(pattern, "i"),
		replace: category.replace,
	}))
);

export function resolveCategory({
	className,
	title,
}: {
	className?: string | null;
	title?: string | null;
}): string | null {
	const candidates = [className, title].filter((value): value is string => Boolean(value && value.length));

	for (const candidate of candidates) {
		for (const { pattern, replace } of categoryMatchers) {
			if (pattern.test(candidate))
				return replace;
		}
	}

	return null;
}