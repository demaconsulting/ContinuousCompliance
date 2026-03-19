using System.Linq;

namespace TemplateReviews;

/// <summary>
/// Provides common string manipulation operations.
/// </summary>
public static class StringHelper
{
    /// <summary>
    /// Returns the characters of the input string in reverse order.
    /// </summary>
    /// <param name="value">The string to reverse.</param>
    /// <returns>A new string with the characters of <paramref name="value"/> in reverse order.</returns>
    public static string Reverse(string value) =>
        new(value.ToCharArray().Reverse().ToArray());

    /// <summary>
    /// Returns the input string converted to upper case.
    /// </summary>
    /// <param name="value">The string to convert.</param>
    /// <returns>A new string with all characters in <paramref name="value"/> converted to upper case.</returns>
    public static string ToUpper(string value) => value.ToUpper();
}
